/* https://www.dustinhorne.com/post/2016/06/09/implementing-a-dictionary-in-typescript */
export interface IKeyedCollection<T> {
  Add(key: string, value: T);
  ContainsKey(key: string): boolean;
  Count(): number;
  Item(key: string): T;
  Keys(): string[];
  Remove(key: string): T;
  Values(): T[];
}
