# example cognito authorizer

API Gateway is configured to use a cognito authorizer

Cognito authorizers are set in the `cognito` module variable:

```
  cognito = {
    proxy = {
      authorizer_id = aws_cognito_user_pool.users.arn
      cognito_domain = join(".", [var.auth_domain, var.project_domain])
      type = "COGNITO_USER_POOLS"
    }
  }
```

+ key is the name of the fargate authorizer group (only `proxy` is valid at the moment).
+ `authorizer_id` is the arn of the cognito user pool
+ `type` must be `COGNITO_USER_POOLS`
