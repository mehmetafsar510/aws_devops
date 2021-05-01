from celery.decorators import task

@task(name="sum_two_numbers")
def add(x, y):
    return x + y