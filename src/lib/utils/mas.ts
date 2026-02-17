/**
 * MAS (Maximum Aerobic Speed) calculation from time trial data
 * Formula: MAS = D ÷ (M × 60 + S) × (0.766 + 0.117 × (D ÷ 1000))
 */
export function computeMAS(distanceM: number, minutes: number, seconds: number): number {
  const totalSeconds = minutes * 60 + seconds;
  const factor = 0.766 + 0.117 * (distanceM / 1000);
  return (distanceM / totalSeconds) * factor;
}

/**
 * Shuttle distance: (distance - 2) / 2
 * Subtract 2m for change of direction cost, then halve
 */
export function applyShuttleDistance(distanceM: number): number {
  return (distanceM - 2) / 2;
}

/**
 * Convert speed m/s to km/h
 */
export function msToKmh(ms: number): number {
  return ms * 3.6;
}

/**
 * Convert speed m/s to pace (min/km)
 */
export function msToPaceMinKm(ms: number): string {
  if (ms <= 0) return "0:00";
  const secPerKm = 1000 / ms;
  const mins = Math.floor(secPerKm / 60);
  const secs = Math.round(secPerKm % 60);
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}
