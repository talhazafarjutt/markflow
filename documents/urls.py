from django.urls import path
from .views import CustomLoginView, DocumentListCreateView, DocumentDetailView

urlpatterns = [
    path('users/<int:id>/login/', CustomLoginView.as_view(), name='custom_login'),
    path('documents/', DocumentListCreateView.as_view(), name='document_list_create'),
    path('documents/<int:id>/', DocumentDetailView.as_view(), name='document_detail'),
]
