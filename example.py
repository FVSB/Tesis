def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n-1)

num = 5
result = factorial(num)
print(f"El factorial de {num} es: {result}")