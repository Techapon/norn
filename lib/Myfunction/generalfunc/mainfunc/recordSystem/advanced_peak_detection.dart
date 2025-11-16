import 'dart:math' as math;

/// ✅ Advanced Peak Detection with Start/End Tracking
/// 
/// This algorithm uses multiple techniques:
/// 1. Statistical peak detection (mean + SD)
/// 2. Slope-based peak detection (rate of change)
/// 3. Adaptive threshold based on local variance
/// 4. Peak start/end boundary detection
class PeakDetectionResult {
  final List<double> values;
  final List<PeakRegion> peaks;
  final List<int> peakIndices;

  PeakDetectionResult({
    required this.values,
    required this.peaks,
    required this.peakIndices,
  });
}

class PeakRegion {
  final int startIndex;
  final int endIndex;
  final double peakValue;
  final int peakIndex;
  final double prominence;
  final String category;

  PeakRegion({
    required this.startIndex,
    required this.endIndex,
    required this.peakValue,
    required this.peakIndex,
    required this.prominence,
    required this.category,
  });
}

/// ✅ Main peak detection function with improved algorithm
/// 
/// Parameters:
///   - data: Input data array
///   - windowSize: Size of sliding window for local statistics (default: 5)
///   - sdMultiplier: Multiplier for standard deviation threshold (default: 2.5)
///   - minProminence: Minimum absolute prominence to consider a peak (default: 2.0)
///   - slopeThreshold: Minimum slope change to detect peak boundaries (default: 0.5)
///   - adaptiveThreshold: Use adaptive threshold based on local variance (default: true)
///   - maxPeaksPerInterval: Maximum number of peaks to keep per interval (default: 10)
PeakDetectionResult detectPeaksAdvanced(
  List<double> data, {
  int windowSize = 5,
  double sdMultiplier = 2.5,
  double minProminence = 2.0,
  double slopeThreshold = 0.5,
  bool adaptiveThreshold = true,
  int maxPeaksPerInterval = 10,
}) {
  if (data.isEmpty) {
    return PeakDetectionResult(
      values: [],
      peaks: [],
      peakIndices: [],
    );
  }

  if (data.length < 3) {
    // Too small, return all data
    return PeakDetectionResult(
      values: List.from(data),
      peaks: [],
      peakIndices: [],
    );
  }

  final List<PeakRegion> detectedPeaks = [];
  final List<int> peakIndices = [];
  final List<double> filteredValues = [];

  // Calculate local statistics for adaptive threshold
  final List<double> localMeans = [];
  final List<double> localSDs = [];
  final List<double> localVariances = [];

  for (int i = 0; i < data.length; i++) {
    final start = math.max(0, i - windowSize);
    final end = math.min(data.length - 1, i + windowSize);
    final window = data.sublist(start, end + 1);

    final mean = window.reduce((a, b) => a + b) / window.length;
    final variance = window
        .map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / window.length;
    final sd = math.sqrt(variance);

    localMeans.add(mean);
    localSDs.add(sd);
    localVariances.add(variance);
  }

  // Detect peaks using multiple criteria
  for (int i = 1; i < data.length - 1; i++) {
    final value = data[i];
    final localMean = localMeans[i];
    final localSD = localSDs[i];
    final localVar = localVariances[i];

    // Calculate prominence (distance from local mean)
    final prominence = (value - localMean).abs();

    // Adaptive threshold: higher threshold in high-variance regions
    final adaptiveSDMult = adaptiveThreshold
        ? sdMultiplier * (1.0 + math.min(localVar / 100.0, 1.0))
        : sdMultiplier;

    // Statistical condition: value is significantly different from neighbors
    final statCondition = localSD > 0
        ? prominence >= localSD * adaptiveSDMult
        : prominence >= minProminence;

    // Slope condition: check if there's a significant change in slope
    final prevSlope = data[i] - data[i - 1];
    final nextSlope = data[i + 1] - data[i];
    final slopeChange = (nextSlope - prevSlope).abs();
    final slopeCondition = slopeChange >= slopeThreshold;

    // Absolute prominence condition
    final absCondition = prominence >= minProminence;

    // Peak detected if meets criteria
    if ((statCondition || slopeCondition) && absCondition) {
      // Find peak boundaries (start and end)
      final boundaries = _findPeakBoundaries(
        data,
        i,
        localMean,
        localSD,
        windowSize,
      );

      // Only add if peak is significant enough
      if (boundaries.endIndex - boundaries.startIndex >= 1) {
        final category = _categorizeValue(value);
        final peak = PeakRegion(
          startIndex: boundaries.startIndex,
          endIndex: boundaries.endIndex,
          peakValue: value,
          peakIndex: i,
          prominence: prominence,
          category: category,
        );

        detectedPeaks.add(peak);
        peakIndices.add(i);
      }
    }
  }

  // ✅ Sort peaks by prominence (most significant first) and keep only top N
  detectedPeaks.sort((a, b) => b.prominence.compareTo(a.prominence));
  final topPeaks = detectedPeaks.length > maxPeaksPerInterval
      ? detectedPeaks.sublist(0, maxPeaksPerInterval)
      : detectedPeaks;

  // ✅ Apply additional filtering: remove peaks too similar to nearby peaks
  final filteredTopPeaks = _filterSimilarPeaks(data, topPeaks);

  // Update peak indices to match filtered peaks
  final topPeakIndices = filteredTopPeaks.map((p) => p.peakIndex).toList();

  // Build filtered data: keep filtered peaks + compress non-peak regions + preserve start/end
  filteredValues.addAll(_buildFilteredDataWithStartEnd(data, filteredTopPeaks));

  return PeakDetectionResult(
    values: filteredValues,
    peaks: filteredTopPeaks,
    peakIndices: topPeakIndices,
  );
}

/// ✅ Filter peaks that are too similar to nearby peaks
/// 
/// Removes peaks if:
/// 1. Previous 1-peak check: Current peak must differ from previous peak by at least 15 units
/// 2. Previous 2-peak check: Current peak must differ from previous 2 peaks by at least 15 units
/// 3. Only peak values are compared (not startPeak/endPeak)
/// 4. If filtered, the peak and its startPeak/endPeak are excluded from stored data
List<PeakRegion> _filterSimilarPeaks(
  List<double> data,
  List<PeakRegion> peaks,
) {
  if (peaks.length <= 1) return peaks;

  // Sort peaks by position (time order) for checking previous peaks
  final sortedByPosition = List<PeakRegion>.from(peaks)
    ..sort((a, b) => a.peakIndex.compareTo(b.peakIndex));

  final List<PeakRegion> filtered = [];
  const double similarityThreshold = 15.0; // ✅ Difference must be at least 15 units

  for (int i = 0; i < sortedByPosition.length; i++) {
    final currentPeak = sortedByPosition[i];
    bool shouldKeep = true;

    // ✅ Step 1: Previous 1-peak check (only compare peak values)
    if (i > 0) {
      final prevPeak = sortedByPosition[i - 1];
      final diffFromPrev = (currentPeak.peakValue - prevPeak.peakValue).abs();
      
      if (diffFromPrev < similarityThreshold) {
        // Too similar to previous peak (difference < 15 units)
        // Exclude this peak and its startPeak/endPeak from stored data
        shouldKeep = false;
      }
    }

    // ✅ Step 2: Previous 2-peak check (only compare peak values)
    // Only check if passed step 1
    if (shouldKeep && i > 1) {
      final prev2Peak = sortedByPosition[i - 2];
      final diffFromPrev2 = (currentPeak.peakValue - prev2Peak.peakValue).abs();
      
      if (diffFromPrev2 < similarityThreshold) {
        // Too similar to 2nd previous peak (difference < 15 units)
        // Exclude this peak and its startPeak/endPeak from stored data
        shouldKeep = false;
      }
    }

    // ✅ Step 3: Peak-only check - only peak values are compared
    // No comparison with startPeak/endPeak boundaries

    if (shouldKeep) {
      filtered.add(currentPeak);
    }
  }

  // Return filtered peaks sorted back by prominence (original order)
  filtered.sort((a, b) => b.prominence.compareTo(a.prominence));
  return filtered;
}

/// ✅ Find start and end boundaries of a peak
class PeakBoundaries {
  final int startIndex;
  final int endIndex;

  PeakBoundaries({
    required this.startIndex,
    required this.endIndex,
  });
}

PeakBoundaries _findPeakBoundaries(
  List<double> data,
  int peakIndex,
  double localMean,
  double localSD,
  int windowSize,
) {
  // Find start: go backwards until value returns to baseline
  int start = peakIndex;
  final baselineThreshold = localMean + (localSD * 0.5);

  for (int i = peakIndex - 1; i >= 0; i--) {
    if (data[i] <= baselineThreshold) {
      start = i + 1;
      break;
    }
    if (i == 0) {
      start = 0;
      break;
    }
  }

  // Find end: go forwards until value returns to baseline
  int end = peakIndex;
  for (int i = peakIndex + 1; i < data.length; i++) {
    if (data[i] <= baselineThreshold) {
      end = i - 1;
      break;
    }
    if (i == data.length - 1) {
      end = data.length - 1;
      break;
    }
  }

  return PeakBoundaries(startIndex: start, endIndex: end);
}

/// ✅ Build filtered data preserving top peaks, start/end values, and compressing non-peak regions
List<double> _buildFilteredDataWithStartEnd(
  List<double> data,
  List<PeakRegion> peaks,
) {
  if (peaks.isEmpty) {
    // No peaks: keep start, end, and adaptive sample
    return _adaptiveDownsampleWithStartEnd(data);
  }

  final List<double> result = [];
  final Set<int> peakIndicesSet = {};
  
  // Collect all indices that are part of top peaks
  for (final peak in peaks) {
    for (int i = peak.startIndex; i <= peak.endIndex; i++) {
      peakIndicesSet.add(i);
    }
  }

  // Always include first value (start)
  result.add(data.first);

  // Process data: keep peaks, compress non-peaks
  int i = 1; // Start from 1 since we already added first
  while (i < data.length - 1) {
    if (peakIndicesSet.contains(i)) {
      // In peak region: keep all values
      PeakRegion? currentPeak;
      for (final peak in peaks) {
        if (i >= peak.startIndex && i <= peak.endIndex) {
          currentPeak = peak;
          break;
        }
      }

      if (currentPeak != null) {
        // ✅ Only store: startPeak boundary + peak value + endPeak boundary (max 3 values per peak)
        // This ensures filtered peaks and their boundaries are excluded
        final startPeakValue = data[currentPeak.startIndex];
        final peakValue = data[currentPeak.peakIndex];
        final endPeakValue = data[currentPeak.endIndex];
        
        // Add startPeak boundary (if within bounds and not duplicate)
        if (currentPeak.startIndex > 0 && currentPeak.startIndex < data.length - 1) {
          if (result.isEmpty || result.last != startPeakValue) {
            result.add(startPeakValue);
          }
        }
        
        // Add peak value itself (if different from what we just added)
        if (currentPeak.peakIndex > 0 && currentPeak.peakIndex < data.length - 1) {
          if (result.isEmpty || result.last != peakValue) {
            result.add(peakValue);
          }
        }
        
        // Add endPeak boundary (if different from peak value and within bounds)
        if (currentPeak.endIndex > 0 && currentPeak.endIndex < data.length - 1) {
          if (result.isEmpty || result.last != endPeakValue) {
            result.add(endPeakValue);
          }
        }
        
        i = currentPeak.endIndex + 1;
      } else {
        result.add(data[i]);
        i++;
      }
    } else {
      // Non-peak region: compress using adaptive sampling
      int nonPeakStart = i;
      while (i < data.length - 1 && !peakIndicesSet.contains(i)) {
        i++;
      }
      int nonPeakEnd = i - 1;

      if (nonPeakEnd >= nonPeakStart) {
        final nonPeakData = data.sublist(nonPeakStart, nonPeakEnd + 1);
        // Compress non-peak regions (sample middle points)
        final compressed = _compressNonPeakRegion(nonPeakData);
        // Skip first of compressed if it's the same as last in result
        for (int j = 0; j < compressed.length; j++) {
          if (j == 0 && result.isNotEmpty && result.last == compressed[j]) {
            continue;
          }
          result.add(compressed[j]);
        }
      }
    }
  }

  // Always include last value (end) if not already added
  if (result.isEmpty || result.last != data.last) {
    result.add(data.last);
  }

  return result;
}


/// ✅ Compress non-peak regions while preserving boundaries
List<double> _compressNonPeakRegion(List<double> data) {
  if (data.length <= 3) {
    return List.from(data);
  }

  // Keep first, last, and sample middle points
  final List<double> compressed = [data.first];

  // Sample middle points (every Nth point based on length)
  final sampleInterval = math.max(1, data.length ~/ 10);
  for (int i = sampleInterval; i < data.length - 1; i += sampleInterval) {
    compressed.add(data[i]);
  }

  compressed.add(data.last);
  return compressed;
}

/// ✅ Adaptive downsampling for regions without peaks (preserves start/end)
List<double> _adaptiveDownsampleWithStartEnd(
  List<double> data, {
  int maxPoints = 50,
}) {
  if (data.length <= 3) {
    return List.from(data);
  }

  if (data.length <= maxPoints) {
    return List.from(data);
  }

  final List<double> downsampled = [data.first]; // Always start with first

  // Sample middle points
  final middlePoints = maxPoints - 2; // Reserve space for first and last
  final step = (data.length - 2) / middlePoints;

  for (int i = 1; i <= middlePoints; i++) {
    final index = 1 + (i * step).round();
    if (index < data.length - 1) {
      downsampled.add(data[index]);
    }
  }

  // Always include last
  downsampled.add(data.last);

  return downsampled;
}


/// ✅ Categorize value based on thresholds
String _categorizeValue(double value) {
  if (0 <= value && value <= 25) return "Apnea";
  if (25 < value && value <= 50) return "Quiet";
  if (50 < value && value <= 75) return "Lound";
  if (75 < value && value <= 100) return "Very Lound";
  return "Unknown";
}

/// ✅ Legacy compatibility: wrapper for old analyzePeakValue function
/// This maintains backward compatibility while using the new algorithm
List<double> analyzePeakValue(
  List<double> data, {
  int window = 2,
  double multiplier = 3,
  double minPromAbs = 1,
}) {
  // Use new algorithm with legacy parameters mapped
  final result = detectPeaksAdvanced(
    data,
    windowSize: window + 1,
    sdMultiplier: multiplier,
    minProminence: minPromAbs,
    slopeThreshold: 0.3,
    adaptiveThreshold: true,
  );

  return result.values;
}


