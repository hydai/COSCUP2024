# syntax=docker/dockerfile:1

FROM scratch
ADD llama-api-server.wasm /
CMD ["/llama-api-server.wasm"]
