set -eu

setup() { 
    ARCH=$1 
    echo ${ARCH}
    valid_arches=(arm x86)
    if ! [[ " ${valid_arches[@]} " =~ " ${ARCH} " ]]; then
        echo "Invalid arch. (arm, x86)"
        exit 1
    fi 

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
        yes 1 | add-apt-repository -y ppa:deadsnakes/ppa
        apt install -y python3.10 python3.11 python3.12
    fi

    if ! [ -x "$(command -v rustc)" ]; then
        echo "INSTALLING RUST"
        yes 1 | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        echo "export PATH=\"\$PATH:/root/.cargo/bin\"" >> /root/.bashrc
    fi

    if ! [ -x "$(command -v go)" ]; then
        echo "INSTALLING GO"

        if [[ ${ARCH} == "${valid_arches[0]}" ]]; then
            curl -L  https://go.dev/dl/go1.22.1.linux-arm64.tar.gz -o go.tar
        elif [[ ${ARCH} == "${valid_arches[1]}" ]]; then
            curl -L  https://go.dev/dl/go1.22.1.linux-amd64.tar.gz -o go.tar
        fi

        tar -xzf go.tar
        mv go /root/go
        echo "export PATH=\"\$PATH:/root/go/bin\"" >> /root/.bashrc

    fi

    if ! [ -x "$(command -v javac)" ]; then
        echo "INSTALLING JAVA"
        # https://jdk.java.net/21/
        if [[ ${ARCH} == "${valid_arches[0]}" ]]; then
            curl -L https://download.java.net/java/GA/jdk22/830ec9fcccef480bb3e73fb7ecafe059/36/GPL/openjdk-22_linux-aarch64_bin.tar.gz -o java.tar
        elif [[ ${ARCH} == "${valid_arches[1]}" ]]; then
            curl -L https://download.java.net/java/GA/jdk22/830ec9fcccef480bb3e73fb7ecafe059/36/GPL/openjdk-22_linux-x64_bin.tar.gz -o java.tar
        fi

        tar -xzf java.tar
        mv jdk-22 /root/jdk
        echo "export PATH=\"\$PATH:/root/jdk/bin\"" >> /root/.bashrc
    fi

    if ! [ -x "$(command -v zig)" ]; then
        echo "INSTALLING ZIG"
        apt install -y xz-utils -y
        if [[ ${ARCH} == "${valid_arches[0]}" ]]; then
            curl -L https://ziglang.org/download/0.11.0/zig-linux-aarch64-0.11.0.tar.xz -o zig.tar
        elif [[ ${ARCH} == "${valid_arches[1]}" ]]; then
            curl -L https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz -o zig.tar
        fi
        mkdir zig
        tar -xf zig.tar -C zig
        mv zig/* /root/zig
        echo "export PATH=\"\$PATH:/root/zig\"" >> /root/.bashrc
    fi

    if ! [ -x "$(command -v swift)" ]; then
        echo "INSTALLING SWIFT"
        apt-get install binutils git gnupg2 libc6-dev libcurl4-openssl-dev libedit2 \
            libgcc-9-dev libncurses6 libpython3.8 libsqlite3-0 libstdc++-9-dev \
            libxml2-dev libz3-dev pkg-config tzdata unzip zlib1g-dev -y

        if [[ ${ARCH} == "${valid_arches[0]}" ]]; then
            curl -L https://download.swift.org/swift-5.10-release/ubuntu2204-aarch64/swift-5.10-RELEASE/swift-5.10-RELEASE-ubuntu22.04-aarch64.tar.gz -o swift.tar
            tar xzf swift.tar
            mkdir swiftlang
            mv swift-5.10-RELEASE-ubuntu22.04/* swiftlang
        elif [[ ${ARCH} == "${valid_arches[1]}" ]]; then
            curl -L https://download.swift.org/swift-5.10-release/ubuntu2204/swift-5.10-RELEASE/swift-5.10-RELEASE-ubuntu22.04.tar.gz -o swift.tar
            tar xzf swift.tar
            mkdir swiftlang
            mv swift-5.10-RELEASE-ubuntu22.04/* swiftlang
        fi
        mv swiftlang /root/swiftlang
        echo "export PATH=\"\$PATH:/root/swiftlang/usr/bin\"" >> /root/.bashrc
    fi

    if ! [ -x "$(command -v "lua")" ]; then
        echo "INSTALLING LUA"
        apt install -y lua5.1 lua5.2 lua5.3 lua5.4
    fi

    echo "run 'source /root/.bashrc' after setup"
}

append_to_file() {
	echo "$1" >> out/"$2".csv
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
        rm syn_zig.o

		echo "Building c++ for zig"
		zig c++ --std=c++20 synthetic_test/syn.cpp -o zig_cpp
		mv zig_cpp out/synthetic/zig_cpp
	fi

	if [ -x "$(command -v swift)" ]; then
		echo "Building for swift"
		swiftc synthetic_test/syn.swift -o out/synthetic/swift
    fi

	echo "RUNNING SYNTHETIC TESTS"
	append_to_file "binary name,binary size (bytes),run1,run2,run3" "synthetic_results"

	if [ -f "out/synthetic/g++_cpp" ]; then
		echo "running g++_cpp"
		size=$(stat -c%s "out/synthetic/g++_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/g++_cpp; } 2>&1 1>/dev/null)

		append_to_file "g++,$size,$time1,$time2,$time3"  "synthetic_results"
	fi

	if [ -f "out/synthetic/clang_cpp" ]; then
		echo "running clang_cpp"
		size=$(stat -c%s "out/synthetic/clang_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/clang_cpp; } 2>&1 1>/dev/null)

		append_to_file "clang,$size,$time1,$time2,$time3"  "synthetic_results"
	fi

	if [ -f "out/synthetic/rust" ]; then
		echo "running rust"
		size=$(stat -c%s "out/synthetic/rust")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/rust; } 2>&1 1>/dev/null)

		append_to_file "rust,$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -f "out/synthetic/golang" ]; then
		echo "running golang"
		size=$(stat -c%s "out/synthetic/golang")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/golang; } 2>&1 1>/dev/null)

		append_to_file "golang,$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -f "out/synthetic/synthetic.class" ]; then
		echo "running java"
		size=$(stat -c%s "out/synthetic/synthetic.class")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/synthetic.class; } 2>&1 1>/dev/null)

		append_to_file "java,$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -f "out/synthetic/zig" ]; then
		echo "running zig"
		size=$(stat -c%s "out/synthetic/zig")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/zig; } 2>&1 1>/dev/null)

		append_to_file "zig,$size,$time1,$time2,$time3" "synthetic_results"
        
		echo "running cpp zig"
		size=$(stat -c%s "out/synthetic/zig_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/zig_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/zig_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/zig_cpp; } 2>&1 1>/dev/null)

		append_to_file "zig,$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -f "out/synthetic/swift" ]; then
		echo "running swift"
		size=$(stat -c%s "out/synthetic/swift")
		time1=$({ TIMEFORMAT="%R"; time out/synthetic/swift; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/synthetic/swift; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/synthetic/swift; } 2>&1 1>/dev/null)

		append_to_file "swift,$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -x "$(command -v 'python3.10')" ]; then
		echo "running python3.10"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.10,$size,$time1,$time2,$time3" "synthetic_results"

		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.10 (untyped),$size,$time1,$time2,$time3" "synthetic_results"
	fi
	
	if [ -x "$(command -v 'python3.11')" ]; then
		echo "running python3.11"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.11,$size,$time1,$time2,$time3" "synthetic_results"
		
		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.11 (untyped),$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -x "$(command -v 'python3.12')" ]; then
		echo "running python3.12"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn.py; } 2>&1 1>/dev/null)
		append_to_file "python3.12,$size,$time1,$time2,$time3" "synthetic_results"

		size=$(stat -c%s "synthetic_test/syn_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 synthetic_test/syn_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.12 (untyped),$size,$time1,$time2,$time3" "synthetic_results"
	fi

	if [ -x "$(command -v 'lua5.1')" ]; then
		echo "running lua5.1"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time lua5.1 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.1 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.1 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.1,$size,$time1,$time2,$time3" "synthetic_results"
    fi

	if [ -x "$(command -v 'lua5.2')" ]; then
		echo "running lua5.2"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time lua5.2 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.2 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.2 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.2,$size,$time1,$time2,$time3" "synthetic_results"
    fi

	if [ -x "$(command -v 'lua5.3')" ]; then
		echo "running lua5.3"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time lua5.3 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.3 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.3 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.3,$size,$time1,$time2,$time3" "synthetic_results"
    fi

	if [ -x "$(command -v 'lua5.4')" ]; then
		echo "running lua5.4"
		size=$(stat -c%s "synthetic_test/syn.py")
		time1=$({ TIMEFORMAT="%R"; time lua5.4 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.4 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.4 synthetic_test/syn.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.4,$size,$time1,$time2,$time3" "synthetic_results"
    fi

	echo "COMPLETE"
}

view_synthetic() {
	if ! [ -x "$(command -v csvtool)" ]; then
		apt install csvtool -y
	fi
	csvtool readable out/synthetic_results.csv | view -
	csvtool readable out/gol_results.csv | view -
}

game-of-life() {
	echo "BUILDING GAME OF LIFE"
	rm -rf out/gol
	mkdir -p out/gol

	if [ -x "$(command -v g++-13)" ]; then
		echo "Building for g++"
		g++-13 -std=c++20 gol_test/gol.cpp -o out/gol/g++_cpp
	fi

	if [ -x "$(command -v clang++-18)" ]; then
		echo "Building for clang++"
		clang++-18 -std=c++20 gol_test/gol.cpp -o out/gol/clang_cpp
	fi

	if [ -x "$(command -v rustc)" ]; then
		echo "Building for rust"
		apt install build-essential -y
		rustc gol_test/gol.rs -o out/gol/rust
	fi

	if [ -x "$(command -v go)" ]; then
		echo "Building for go"
		go build -o out/gol/golang gol_test/gol.go
	fi

	if [ -x "$(command -v javac)" ]; then
		echo "Building for java"
		# NOTE: Java build files (*.class) can't have a different name to the source code files
		javac -d out/gol gol_test/gol.java 
	fi

	if [ -x "$(command -v zig)" ]; then
		echo "Building for zig"
		zig build-exe gol_test/gol.zig --name gol_zig
		mv gol_zig out/gol/zig

		echo "Building c++ for zig"
		zig c++ --std=c++20 gol_test/gol.cpp -o zig_cpp
		mv zig_cpp out/gol/zig_cpp
	fi

	if [ -x "$(command -v swift)" ]; then
		echo "Building for swift"
		swiftc gol_test/gol.swift -o out/gol/swift
    fi

	echo "RUNNING GAME OF LIFE TESTS"
	append_to_file "binary name,binary size (bytes),run1,run2,run3" "gol_results"

	if [ -f "out/gol/g++_cpp" ]; then
		echo "running g++_cpp"
		size=$(stat -c%s "out/gol/g++_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/gol/g++_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/g++_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/g++_cpp; } 2>&1 1>/dev/null)

		append_to_file "g++,$size,$time1,$time2,$time3"  "gol_results"
	fi

	if [ -f "out/gol/clang_cpp" ]; then
		echo "running clang_cpp"
		size=$(stat -c%s "out/gol/clang_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/gol/clang_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/clang_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/clang_cpp; } 2>&1 1>/dev/null)

		append_to_file "clang,$size,$time1,$time2,$time3"  "gol_results"
	fi

	if [ -f "out/gol/rust" ]; then
		echo "running rust"
		size=$(stat -c%s "out/gol/rust")
		time1=$({ TIMEFORMAT="%R"; time out/gol/rust; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/rust; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/rust; } 2>&1 1>/dev/null)

		append_to_file "rust,$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -f "out/gol/golang" ]; then
		echo "running golang"
		size=$(stat -c%s "out/gol/golang")
		time1=$({ TIMEFORMAT="%R"; time out/gol/golang; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/golang; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/golang; } 2>&1 1>/dev/null)

		append_to_file "golang,$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -f "out/gol/gol.class" ]; then
		echo "running java"
		size=$(stat -c%s "out/gol/gol.class")
		time1=$({ TIMEFORMAT="%R"; time out/gol/gol.class; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/gol.class; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/gol.class; } 2>&1 1>/dev/null)

		append_to_file "java,$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -f "out/gol/zig" ]; then
		echo "running zig"
		size=$(stat -c%s "out/gol/zig")
		time1=$({ TIMEFORMAT="%R"; time out/gol/zig; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/zig; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/zig; } 2>&1 1>/dev/null)

		append_to_file "zig,$size,$time1,$time2,$time3" "gol_results"
        
		echo "running cpp zig"
		size=$(stat -c%s "out/gol/zig_cpp")
		time1=$({ TIMEFORMAT="%R"; time out/gol/zig_cpp; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/zig_cpp; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/zig_cpp; } 2>&1 1>/dev/null)

		append_to_file "zig,$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -f "out/gol/swift" ]; then
		echo "running swift"
		size=$(stat -c%s "out/gol/swift")
		time1=$({ TIMEFORMAT="%R"; time out/gol/swift; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time out/gol/swift; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time out/gol/swift; } 2>&1 1>/dev/null)

		append_to_file "swift,$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -x "$(command -v 'python3.10')" ]; then
		echo "running python3.10"
		size=$(stat -c%s "gol_test/gol.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol.py; } 2>&1 1>/dev/null)
		append_to_file "python3.10,$size,$time1,$time2,$time3" "gol_results"

		size=$(stat -c%s "gol_test/gol_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.10 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.10 (untyped),$size,$time1,$time2,$time3" "gol_results"
	fi
	
	if [ -x "$(command -v 'python3.11')" ]; then
		echo "running python3.11"
		size=$(stat -c%s "gol_test/gol.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol.py; } 2>&1 1>/dev/null)
		append_to_file "python3.11,$size,$time1,$time2,$time3" "gol_results"
		
		size=$(stat -c%s "gol_test/gol_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.11 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.11 (untyped),$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -x "$(command -v 'python3.12')" ]; then
		echo "running python3.12"
		size=$(stat -c%s "gol_test/gol.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol.py; } 2>&1 1>/dev/null)
		append_to_file "python3.12,$size,$time1,$time2,$time3" "gol_results"

		size=$(stat -c%s "gol_test/gol_untyped.py")
		time1=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time python3.12 gol_test/gol_untyped.py; } 2>&1 1>/dev/null)

		append_to_file "python3.12 (untyped),$size,$time1,$time2,$time3" "gol_results"
	fi

	if [ -x "$(command -v 'lua5.1')" ]; then
		echo "running lua5.1"
		size=$(stat -c%s "gol_test/gol.lua")
		time1=$({ TIMEFORMAT="%R"; time lua5.1 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.1 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.1 gol_test/gol.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.1,$size,$time1,$time2,$time3" "gol_results"
    fi

	if [ -x "$(command -v 'lua5.2')" ]; then
		echo "running lua5.2"
		size=$(stat -c%s "gol_test/gol.lua")
		time1=$({ TIMEFORMAT="%R"; time lua5.2 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.2 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.2 gol_test/gol.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.2,$size,$time1,$time2,$time3" "gol_results"
    fi

	if [ -x "$(command -v 'lua5.3')" ]; then
		echo "running lua5.3"
		size=$(stat -c%s "gol_test/gol.lua")
		time1=$({ TIMEFORMAT="%R"; time lua5.3 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.3 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.3 gol_test/gol.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.3,$size,$time1,$time2,$time3" "gol_results"
    fi

	if [ -x "$(command -v 'lua5.4')" ]; then
		echo "running lua5.4"
		size=$(stat -c%s "gol_test/gol.lua")
		time1=$({ TIMEFORMAT="%R"; time lua5.4 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time2=$({ TIMEFORMAT="%R"; time lua5.4 gol_test/gol.lua; } 2>&1 1>/dev/null)
		time3=$({ TIMEFORMAT="%R"; time lua5.4 gol_test/gol.lua; } 2>&1 1>/dev/null)
		append_to_file "lua5.4,$size,$time1,$time2,$time3" "gol_results"
    fi

    echo "COMPLETE"
}

clean() {
	echo "CLEANING"
    rm -rf *.tar
    rm gol_zig.o 
    rm llvm.sh
    rm -rf swift*
    rm -rf zig
}

if [ $# -eq 0 ]; then
	echo "no command specified"
	echo "(valid options: gol, setup, synthetic, view-results)"
	exit 0
elif [ $1 == "setup" ]; then
	setup $2
	exit 0
elif [ $1 == "synthetic" ]; then
	synthetic
	exit 0
elif [ $1 == "view-results" ]; then
	view-synthetic
	exit 0
elif [ $1 == "gol" ]; then
    game-of-life
    exit 0
elif [ $1 == "clean" ]; then
    clean
    exit 0
fi
