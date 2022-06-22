### Protostuffs [ for extending ]

For generating protos ( if editing things ):

`protoc -I=proto --python_out=starting_point proto/message.proto`

`protoc -I proto --go_out=payment_service proto/message.proto`

`protoc -I proto --go_out=...`

I found: https://docs.buf.build/introduction

Initial explorations seem interesting, but I'm happy enough with `protoc ...` and the slight bit of orchestration and needed [dis-]order that comes with managing .proto files shared across services.

Also, see:  https://github.com/bufbuild/buf


