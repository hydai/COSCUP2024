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
