
set -eu

setup() { 
	# TODO: Compile c++ using zig
	echo "SETTING UP ENVIRONMENT..."
	apt update
	apt install -y curl

	if ! [ -x "$(command -v "g++-13")" ]; then
		echo "INSTALLING GDB"
		apt install software-properties-common -y
		add-apt-repository -y ppa:ubuntu-toolchain-r/test
		apt update 
		apt install -y g++-13
	fi

	if ! [ -x "$(command -v "clang++-18")" ]; then
		echo "INSTALLING CLANG"
		apt install lsb-release wget software-properties-common gnupg -y
		curl https://apt.llvm.org/llvm.sh -o llvm.sh
		bash llvm.sh
	fi

	if ! [ -x "$(command -v "python3.11")" ]; then
		echo "INSTALLING PYTHON"
		add-apt-repository -y ppa:deadsnakes/ppa
		apt install -y python3.11 python3.12
	fi

	if ! [ -x "$(command -v rustc)" ]; then
		echo "INSTALLING RUST"
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
		echo "export PATH=\"\$PATH:/root/.cargo/bin\"" >> /root/.bashrc
	fi

	if ! [ -x "$(command -v go)" ]; then
		echo "INSTALLING GO"
		curl -L  https://go.dev/dl/go1.21.6.linux-arm64.tar.gz -o go.tar
		tar -xzf go.tar
		mv go /root/go
		echo "export PATH=\"\$PATH:/root/go/bin\"" >> /root/.bashrc
		
	fi

	if ! [ -x "$(command -v javac)" ]; then
		echo "INSTALLING JAVA"
		# https://jdk.java.net/21/
		curl -L https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-aarch64_bin.tar.gz -o java.tar
	       	tar -xzf java.tar
		mv jdk-21.0.2 /root/jdk
		echo "export PATH=\"\$PATH:/root/jdk/bin\"" >> /root/.bashrc
	fi

	if ! [ -x "$(command -v zig)" ]; then
		echo "INSTALLING ZIG"
		apt install -y xz-utils
		curl -L https://ziglang.org/builds/zig-linux-aarch64-0.12.0-dev.2341+92211135f.tar.xz -o zig.tar
		mkdir zig
		tar -xf zig.tar -C zig
		mv zig/zig-linux-aarch64-0.12.0-dev.2341+92211135f /root/zig
		echo "export PATH=\"\$PATH:/root/zig\"" >> /root/.bashrc
	fi

	echo "run 'source /root/.bashrc' after setup"
}

append_to_file() {
	echo "$1" >> out/synthetic_results.csv
}

synthetic()  {
	echo "BUILDING SYNTHETIC TESTS"
	if [[ -z "${SPEEDTEST_ITERS}" ]]; then
		echo "set SPEEDTEST_ITERS"
		return
	else 
		echo "Iterations: $SPEEDTEST_ITERS"
	fi

	rm -rf out/synthetic
	mkdir -p out/synthetic

	if [ -x "$(command -v g++-13)" ]; then
		echo "Building for g++"
		g++-13 -std=c++20 synthetic_test/syn.cpp -o out/synthetic/g++_cpp
	fi

	if [ -x "$(command -v clang++-18)" ]; then
		echo "Building for clang++"
		clang++-18 -std=c++20 synthetic_test/syn.cpp -o out/synthetic/clang_cpp
	fi

	if [ -x "$(command -v rustc)" ]; then
		echo "Building for rust"
		apt install build-essential -y
		rustc synthetic_test/syn.rs -o out/synthetic/rust
	fi

	if [ -x "$(command -v go)" ]; then
		echo "Building for go"
		go build -o out/synthetic/golang synthetic_test/syn.go
	fi

	if [ -x "$(command -v javac)" ]; then
		echo "Building for java"
		# NOTE: Java build files (*.class) can't have a different name to the source code files
		javac -d out/synthetic synthetic_test/syn.java 
	fi

	if [ -x "$(command -v zig)" ]; then
		echo "Building for zig"
		zig build-exe synthetic_test/syn.zig --name syn_zig
		mv syn_zig out/synthetic/zig
	fi

	echo "RUNNING TESTS"
	append_to_file "binary name,binary size (bytes),run1,run2,run3"

	if [ -f "out/synthetic/g++_cpp" ]; then
		echo "running g++_cpp"
		size=$(stat -c%s "out/synthetic/g++_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)

		append_to_file "g++,$size,$time1,$time2,$time3"
	fi

	if [ -f "out/synthetic/clang_cpp" ]; then
		echo "running clang_cpp"
		size=$(stat -c%s "out/synthetic/clang_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)

		append_to_file "clang,$size,$time1,$time2,$time3"
	fi

	if [ -f "out/synthetic/rust" ]; then
		echo "running rust"
		size=$(stat -c%s "out/synthetic/rust")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)

		append_to_file "rust,$size,$time1,$time2,$time3"
	fi

	if [ -f "out/synthetic/golang" ]; then
		echo "running golang"
		size=$(stat -c%s "out/synthetic/golang")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)

		append_to_file "golang,$size,$time1,$time2,$time3"
	fi

	if [ -f "out/synthetic/synthetic.class" ]; then
		echo "running java"
		size=$(stat -c%s "out/synthetic/synthetic.class")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)

		append_to_file "java,$size,$time1,$time2,$time3"
	fi

	if [ -f "out/synthetic/zig" ]; then
		echo "running zig"
		size=$(stat -c%s "out/synthetic/zig")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)

		append_to_file "zig,$size,$time1,$time2,$time3"
	fi

	if [ -x "$(command -v 'python3.10')" ]; then
		echo "running python3.10"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.10,$size,$time1,$time2,$time3"

		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.10 (untyped),$size,$time1,$time2,$time3"
	fi
	
	if [ -x "$(command -v 'python3.11')" ]; then
		echo "running python3.11"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.11,$size,$time1,$time2,$time3"
		
		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.11 (untyped),$size,$time1,$time2,$time3"
	fi

	if [ -x "$(command -v 'python3.12')" ]; then
		echo "running python3.12"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.12,$size,$time1,$time2,$time3"

		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.12 (untyped),$size,$time1,$time2,$time3"
	fi

	echo "COMPLETE"
}

view_synthetic() {
	if ! [ -x "$(command -v csvtool)" ]; then
		apt install csvtool -y
	fi
	csvtool readable out/synthetic_results.csv | view -
}

if [ $# -eq 0 ]; then
	echo "no command specified"
	echo "(valid options: setup, synthetic)"
	exit 0
elif [ $1 == "setup" ]; then
	setup
	exit 0
elif [ $1 == "synthetic" ]; then
	synthetic
	exit 0
elif [ $1 == "synthetic" ]; then
	view-syn
	exit 0
fi
