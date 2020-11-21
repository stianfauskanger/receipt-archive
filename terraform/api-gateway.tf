resource "aws_apigatewayv2_api" "main_api_gateway" {
  name          = "main_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_security_group" "main_api_gateway_security_group" {
  name        = "main_api_gateway_security_group"
  description = "Security group for API gateway"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "api_gw_vpc_link" {
  name               = "api_gw_vpc_link"
  security_group_ids = [aws_security_group.main_api_gateway_security_group.id]
  subnet_ids         = [aws_subnet.public_subnet_az_a.id, aws_subnet.public_subnet_az_b.id, aws_subnet.public_subnet_az_c.id]
}

resource "aws_lambda_permission" "api_gw_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_signed_upload_url_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main_api_gateway.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.main_api_gateway.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Lambda example"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.generate_signed_upload_url_lambda.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  api_id           = aws_apigatewayv2_api.main_api_gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "jwt_authorizer"

  jwt_configuration {
    audience = ["https://kvittering.ludi.no"]
    issuer   = "https://ludi.eu.auth0.com/"
  }
}

variable "get_upload_receipt_url_path" { default = "/get_upload_receipt_url" }

resource "aws_apigatewayv2_route" "get_upload_receipt_url" {
  api_id               = aws_apigatewayv2_api.main_api_gateway.id
  authorizer_id        = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type   = "JWT"
  authorization_scopes = ["https://kvittering.ludi.no/use"]
  route_key            = "GET ${var.get_upload_receipt_url_path}"
  target               = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.main_api_gateway.id
  name        = "prod"
  auto_deploy = true
  depends_on = [aws_apigatewayv2_route.get_upload_receipt_url]
}
