# KCD Taipei x COSCUP2024 - Develop and deploy lightweight Wasm+LLM containers

## Slide
[Link](https://docs.google.com/presentation/d/1V6Xr9SZrCB9aaIZd56pGrNDXMn7wK5Q8ZERGMH92jJs/edit?usp=sharing)

## Build llamaedge

If you don't want to build it, you can download the pre-built assets instead.

### Install Rust

Install Rust on your system if you want to build from source for the wasm applications.

[Check the official website to install Rust](https://www.rust-lang.org/tools/install)

```console
# Ensure you enable the wasm target for Rust
rustup target add wasm32-wasip1
```

### Compile llamaedge

```console
git clone git@github.com:LlamaEdge/LlamaEdge.git
cd LlamaEdge/api-server
cargo build --release --target wasm32-wasip1
# The built wasm is here
cp ./target/wasm32-wasip1/release/llama-api-server.wasm ../../
```

### Download llamaedge instead

```console
curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm
```

### Package it into the container

Make sure `llama-api-server.wasm` and `dockerfile` is in the same folder.

Dockerfile:
```dockerfile
# syntax=docker/dockerfile:1

FROM scratch
ADD llama-api-server.wasm /
CMD ["/llama-api-server.wasm"]
```

Package:

```console
docker buildx build . --platform wasip1/wasm -t hydai/coscup2024:llama-api-server
```

Publish:

```console
docker push hydai/coscup2024:llama-api-server
```

## Inside Container

### Docker/Podman

Please follow this guide to setup:

[Docker + crun + GPU](https://wasmedge.org/docs/develop/deploy/gpu/docker_wasm_gpu)

#### Start the server

```console
# The first two lines are mapping WasmEdge plugins for enabling the Wasm+LLM support
# The cuda related lines are required if you want to use CUDA. Otherwise, it can run with CPU only.
# We also need to map the model folder to `/resource` because we don't want to package a whole model into a container image.
# There are some environment variables are needed for the safety issue. It will let `crun` know which plugins and models can be accessed.
docker run \
	-v ~/.wasmedge/plugin/libwasmedgePluginWasiNN.so:/.wasmedge/plugin/libwasmedgePluginWasiNN.so \
	-v ~/.wasmedge/plugin/libwasmedgePluginWasiLogging.so:/.wasmedge/plugin/libwasmedgePluginWasiLogging.so \
	-v /usr/local/cuda/targets/x86_64-linux/lib/libcudart.so.12:/lib/x86_64-linux-gnu/libcudart.so.12 \
	-v /usr/local/cuda/targets/x86_64-linux/lib/libcublas.so.12:/lib/x86_64-linux-gnu/libcublas.so.12 \
	-v /usr/local/cuda/targets/x86_64-linux/lib/libcublasLt.so.12:/lib/x86_64-linux-gnu/libcublasLt.so.12 \
	-v /lib/x86_64-linux-gnu/libcuda.so.1:/lib/x86_64-linux-gnu/libcuda.so.1 \
	-v /disk:/resource \
	--env WASMEDGE_PLUGIN_PATH=/.wasmedge/plugin \
	--env WASMEDGE_WASINN_PRELOAD=default:GGML:AUTO:/resource/Meta-Llama-3-8B-Instruct-Q5_K_M.gguf \
	--env n_gpu_layers=100 \
	-p 8080:8080 \
	--rm --device nvidia.com/gpu=all --runtime=crun --annotation=module.wasm.image/variant=compat-smart --platform wasip1/wasm \
	hydai/coscup2024:llama-api-server llama-api-server.wasm -p llama-3-chat
```

#### Interact

Check model list:

```console
curl -X POST http://localhost:8080/v1/models -H 'accept:application/json'
```

Ask questions:

```console
curl -X POST http://localhost:8080/v1/chat/completions \
	-H 'accept:application/json' \
	-H 'Content-Type: application/json' \
	-d '{"messages":[{"role":"system", "content": "You are a helpful assistant."}, {"role":"user", "content": "What is the capital of Japan?"}], "model":"default"}' \
	| jq .
```

### k8s

Please follow this guide to setup:

[k8s + crun](https://github.com/second-state/wasmedge-containers-examples/tree/main/k8s_containerd_llama)

#### Results

[GitHub Action logs](https://github.com/second-state/wasmedge-containers-examples/actions/runs/10189475333/job/28187582098)
