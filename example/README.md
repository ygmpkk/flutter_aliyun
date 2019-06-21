# aliyun_example

Demonstrates how to use the aliyun plugin.

## Getting Started

````
await Aliyun.setup(
    project: "YOUR PROJECt",
    logStore: "YOUR LOG STORE",
    accessKeyId: "YOUR ACCESS KEY ID",
    accessKeySecret: "YOUR ACCESS KEY SECRET",
);

await Aliyun.post(data: {
    'foo': 'bar',
    'bool': "true",
    "num": "1",
});

await Aliyun.post(data: {
    'foo': 'bar2',
    'bool': "true",
    "num": "1",
});

await Aliyun.post(data: {
    'foo': 'bar3',
    'bool': "true",
    "num": "1",
});


await Aliyun.post(data: {
    'foo': 'bar4',
    'bool': "true",
    "num": "1",
});
```


This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
````
