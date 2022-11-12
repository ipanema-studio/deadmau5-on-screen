final int sampling_num = 4096;
final int avg_num_mid = 4;
final int avg_num_treble = 32;

int[] i_bass = {2, 3, 4, 5, 6, 7, 8, 9, 10};          // 20~100Hz (++10)
int[] i_mid = {4, 6, 9, 11, 13, 16, 18, 20, 23};      // 200~1000Hz (++100)
int[] i_treble = {5, 8, 11, 14, 17, 20, 23, 26, 29};  // 2000~10000Hz (++1000)
float[] w_bass;        // A-Weighting (Equal Loudness Contour)
float[] w_mid;
float[] w_treble;

void calculateWeight() {
  for (int i = 0; i != w_bass.length; i++) {
    w_bass[i] = a_weighting(fft_bass.indexToFreq(i_bass[i]));
    w_mid[i] = a_weighting(fft_mid.getAverageCenterFrequency(i_mid[i]));
    w_treble[i] = a_weighting(fft_treble.getAverageCenterFrequency(i_treble[i]));
  }
}

float a_weighting(float frequency) {
  float f_2 = pow(frequency, 2);
  float f_4 = pow(f_2, 2);
  float r = (pow(12194, 2) * f_4) / ((f_2 + pow(20.6, 2)) * sqrt((f_2 + pow(107.7, 2)) * (f_2 + pow(737.9, 2))) * (f_2 + pow(12194, 2)));
  return (r * pow(10, 0.1));
}
