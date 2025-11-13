import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitor {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  // Track screen load time
  static Future<void> trackScreenLoad(
    String screenName,
    Future<void> Function() loadFunction,
  ) async {
    final trace = _performance.newTrace('screen_load_$screenName');
    await trace.start();
    
    try {
      await loadFunction();
      trace.putAttribute('status', 'success');
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // Track API call
  static Future<T> trackApiCall<T>(
    String apiName,
    Future<T> Function() apiFunction,
  ) async {
    final trace = _performance.newTrace('api_$apiName');
    await trace.start();
    
    try {
      final result = await apiFunction();
      trace.putAttribute('status', 'success');
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // Track image load
  static Future<void> trackImageLoad(
    String imageUrl,
    Future<void> Function() loadFunction,
  ) async {
    final trace = _performance.newTrace('image_load');
    trace.putAttribute('url', imageUrl);
    await trace.start();
    
    try {
      await loadFunction();
      trace.putAttribute('status', 'success');
    } catch (e) {
      trace.putAttribute('status', 'error');
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // Track custom metric
  static Future<void> trackCustomMetric(
    String metricName,
    int value,
  ) async {
    final trace = _performance.newTrace(metricName);
    await trace.start();
    trace.setMetric(metricName, value);
    await trace.stop();
  }

  // Enable/disable performance monitoring
  static Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _performance.setPerformanceCollectionEnabled(enabled);
  }
}
