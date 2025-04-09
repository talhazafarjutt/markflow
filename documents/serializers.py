from rest_framework import serializers
from .models import Document, Tag

class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = ['id', 'name']

class DocumentSerializer(serializers.ModelSerializer):
    tags = TagSerializer(many=True, required=False)

    class Meta:
        model = Document
        fields = ['id', 'title', 'content', 'tags', 'created', 'updated']
        read_only_fields = ['created', 'updated']

    def create(self, validated_data):
        tags_data = validated_data.pop('tags', [])
        document = Document.objects.create(**validated_data)
        for tag_data in tags_data:
            tag, created = Tag.objects.get_or_create(**tag_data)
            document.tags.add(tag)
        return document

    def update(self, instance, validated_data):
        tags_data = validated_data.pop('tags', None)
        instance.title = validated_data.get('title', instance.title)
        instance.content = validated_data.get('content', instance.content)
        instance.save()

        if tags_data is not None:
            # Clear current tags and update new ones
            instance.tags.clear()
            for tag_data in tags_data:
                tag, created = Tag.objects.get_or_create(**tag_data)
                instance.tags.add(tag)
        return instance
