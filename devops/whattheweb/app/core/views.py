from django.shortcuts import render
from .tasks import add

# Create your views here.

def index(request):
    add.delay(7, 8)
    return render(request, "index.html")