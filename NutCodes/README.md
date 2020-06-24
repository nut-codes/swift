# NutCodes

This package is a Swift implementation of the [Nut Code](https://nut.codes/) nutrition information encoding format. 

## Creating a Nut Code

The primary use case for creating a Nut Code is to distribute nutrition information to other apps and services. To create a Nut Code, first create a `Food` object, and set its properties:

```Swift

let hazelnuts = Food(fat: 9.0, protein: 2.1, carbohydrates: 2.3)

tenHazelnuts.fiber = 1.4
tenHazelnuts.sugar = 0.6
// ...
```

Next, use the `urlify` method of the `NutCode` struct to create a  `nut` URL. 

```Swift
let url = NutCode.urlify(tenHazelnuts)
```
You can now  

## Parsing a Nut Code
