curl -X POST http://localhost:8080/v1/chat/completions \
	-H 'accept:application/json' \
	-H 'Content-Type: application/json' \
	-d '{"messages":[{"role":"system", "content": "You are a helpful assistant."}, {"role":"user", "content": "What is the capital of Japan?"}], "model":"default"}' \
	| jq .
