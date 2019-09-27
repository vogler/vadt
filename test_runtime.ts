class Foo {
  b: boolean;
  n: number = 42;
  neg(){
    this.b = !this.b;
  }
  fa: () => number; // not a method -> not listed as property
  fb() { return 1; };
}

console.log(Object.getOwnPropertyDescriptors(Foo)); // length, prototype, name
console.log(Object.getOwnPropertyDescriptors(Foo.prototype)); // constructor, neg, fb
 // why does this only output methods but not properties? pretty stupid name...

const o = new Foo();
// console.log(Object.entries(Foo.prototype)); // []
// console.log(Object.keys(Foo.prototype)); // []
// console.log(Object.keys(o)); // []
// console.log(o.toString());
// console.log(Object.getPrototypeOf(o).toString());

// https://stackoverflow.com/questions/40636292/get-properties-of-a-class
// says only defined properties are included in the resulting JS
// but then n = 42 above should be included...

type t = keyof Foo;
// console.log(t);
const d = {x: 123, y: "foo"};
type td = typeof d;
console.log(Object.entries(d));
