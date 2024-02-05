class Syn {
	public static void main(String[] args) {
		String iters_str = System.getenv("SPEEDTEST_ITERS");
		int iters = Integer.parseInt(iters_str);

		for (int i = 0; i < iters; i++) {
			int[] array = new int[1000];
			for (int j = 0; j < 100; j++) { array[j] = j; }
		
			for (int j = 0; j < 10; j++) {
				int tmp = array[j];
				array[j] = array[1000 - (10 - j)];
				array[1000 - (10 - j)] = tmp;
			}
		}
	}
}
