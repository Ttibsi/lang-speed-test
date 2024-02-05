use std::env;

fn main() {
    if let Ok(iters) = env::var("SPEEDTEST_ITERS") {
        for _ in 0..iters.parse::<i32>().unwrap() {
            let mut array: [i32; 1000] = [0; 1000];

            for i in 0..100 {array[i] = i as i32;}
            for i in 0..10 {
                let tmp = array[i];
                array[i] = array[1000-(10-i)];
                array[1000-(10-i)] = tmp;
            }
        }
    }
}
