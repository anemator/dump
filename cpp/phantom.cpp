// Sketch of a type-safe socket API, modeled after
// https://github.com/janestreet/async_unix/blob/41fda63d8a06cf3ca22413ee5a3f015f0813e2cb/src/unix_syscalls.mli#L391
struct Active {};
struct Bound {};
struct Passive {};
struct Unconnected {};
template<typename> struct Socket {};

template<typename Out, typename In> Socket<Out> connect(Socket<In>);
template<> Socket<Active> connect(Socket<Unconnected>) { return Socket<Active>(); }
template<> Socket<Active> connect(Socket<Bound>) { return Socket<Active>(); }

template<typename Out, typename In> Socket<Out> bind(Socket<In>);
template<> Socket<Bound> bind(Socket<Unconnected>) { return Socket<Bound>(); }

template<typename Out, typename In> Socket<Out> listen(Socket<In>);
template<> Socket<Passive> listen(Socket<Bound>) { return Socket<Passive>(); }

template<typename Out, typename In> Socket<Out> accept(Socket<In>);
template<> Socket<Active> accept(Socket<Passive>) { return Socket<Active>(); }

int main() {
  Socket<Unconnected> socket;
  /*const auto active1 = */connect<Active>(socket);
  const auto bound = bind<Bound>(socket);
  /*const auto active2 = */connect<Active>(bound);
  const auto passive = listen<Passive>(bound);
  /*const auto active3 = */accept<Active>(passive);

  // State transitions are encoded in the types, so these calls fail...
  //connect<Active>(active1);
  //connect<Active>(passive);
  //bind<Bound>(active1);
  // ...

  return 0;
}
