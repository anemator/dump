object E2_1 {
  def fib(n: Int) = {
    def rec(count: Int, prev: Int, curr: Int): Int =
      if (count == n) curr else rec(count+1, curr, prev+curr)
    rec(2, 0, 1)
  }
}

object E2_2 {
  def isSorted[A](as: Array[A])(ordered: (A,A) => Boolean): Boolean = {
    def loop(i: Int): Boolean = {
      if (i >= as.size) true
      else if (ordered(as(i-1), as(i))) loop(i+1)
      else false
    }
    as.size < 2 || loop(1)
  }
}

object E2_3 {
  def curry[A,B,C](f: (A,B) => C): A => (B => C) = (a) => (b) => f(a,b)
}

object E2_4 {
  def uncurry[A,B,C](f: A => B => C): (A,B) => C = (a,b) => f(a)(b)
}

object E2_5 {
  def compose[A,B,C](f: B => C, g: A => B): A => C = (a) => f(g(a))
}

object E3_2 {
  def tail[A](as: List[A]): List[A] = as match {
    case hd::tl => tl
    case Nil => Nil
  }
}

object E3_3 {
  def setHead[A](a: A, as: List[A]): List[A] = as match {
    case _::tl => a::tl
    case Nil => List(a)
  }
}

object E3_4 {
  def drop[A](as: List[A], n: Int): List[A] = {
    if (n <= 0) as
    else as match {
      case _::tl => drop(tl, n-1)
      case Nil => Nil
    }
  }
}

object E3_5 {
  def dropWhile[A](as: List[A], f: A => Boolean): List[A] = as match {
    case hd::tl => if (f(hd)) dropWhile(tl, f) else as
    case Nil => Nil
  }
}

object E3_6 {
  def init[A](as: List[A]): List[A] = as match {
    case hd::tl => if (tl.isEmpty) as else init(tl)
    case Nil => Nil
  }
}

object E3_7 {
  // product can't short-circuit on 0.0 because foldRight isn't tail
  // recursive and scala is eager by default. A lazy version of foldRight
  // would terminate immediately on 0.0
}

object Ch3 {
  def foldRight[A,B](as: List[A], z:B)(f: (A,B) => B): B = as match {
    case hd::tl => f(hd, foldRight(tl, z)(f))
    case Nil => z
  }
}

object E3_8 {
  def demo() = {
    // List constructors and foldRight are isomorphic
    Ch3.foldRight(List(1,2,3), Nil:List[Int])((a,b) => a::b)
  }
}

object E3_9 {
  def length[A](as: List[A]): Int = Ch3.foldRight(as, 0)((a,b) => 1+b)
}

object E3_10 {
  // foldLeft(List(4,5,6), 0)(+)
  // loop(0+4, List(5,6))
  // loop((0+4)+5, List(6))
  // loop(((0+4)+5+)+6, Nil)
  // 15
  def foldLeft[A,B](as: List[A], z: B)(f: (B,A) => B): B = {
    def loop(acc: B, rest: List[A]): B = rest match {
      case hd::tl => loop(f(acc, hd), tl)
      case Nil => acc
    }
    loop(z, as)
  }
}

object E3_11 {
  def sum(as: List[Int]): Int = E3_10.foldLeft(as, 0)(_+_)

  def product(as: List[Int]): Int = E3_10.foldLeft(as, 1)((_*_))

  def length[A](as: List[A]): Int = E3_10.foldLeft(as, 0)((b,_) => b+1)
}

object E3_12 {
  def reverse[A](as: List[A]): List[A] =
    E3_10.foldLeft(as, List[A]())((b:List[A],a:A) => a::b)
}

object E3_13 {
  // TODO
  // def foldRight[A,B](as: List[A], z: B)(f: (A,B) => B): B = {
  // }
}

object E3_14 {
  def appendl[A](a1: List[A], a2: List[A]): List[A] =
    E3_10.foldLeft(E3_12.reverse(a1), a2)((a20,a10) => a10::a20)

  def appendr[A](a1: List[A], a2: List[A]): List[A] =
    Ch3.foldRight(a1, a2)(_::_)
}

object E3_15 {
  // O(n) < O(result.size)
  def concat[A](as: List[List[A]]): List[A] = {
    Ch3.foldRight(as, List[A]())((a,b) => E3_14.appendr(a,b))
  }
}

object E3_16 {
  def map[A,B](as: List[A])(f: A => B): List[B] = as match {
    case hd::tl => f(hd) :: map(tl)(f)
    case Nil => Nil
  }

  def add1(as: List[Int]): List[Int] = map(as)(_+1)
}

object E3_17 {
  def toStringList(as: List[Double]): List[String] = E3_16.map(as)(_.toString)
}

object E3_18 {
  // see also E3_16.map

  def mapl[A,B](as: List[A])(f: A => B): List[B] =
    E3_10.foldLeft(E3_12.reverse(as), List[B]())((b,a) => f(a)::b)

  def mapr[A,B](as: List[A])(f: A => B): List[B] =
    Ch3.foldRight(as, List[B]())(f(_) :: _)
}

object E3_19 {
  def filter[A](as: List[A])(f: A => Boolean): List[A] =
    Ch3.foldRight(as, List[A]())((a,b) => if (f(a)) a::b else b)
}

object E3_20 {
  def flatMap[A,B](as: List[A])(f: A => List[B]): List[B] =
    E3_10.foldLeft(E3_12.reverse(as), List[B]())((b,a) => E3_14.appendr(f(a), b))
}

object E3_21 {
  def filter[A](as: List[A])(f: A => Boolean): List[A] =
    E3_20.flatMap(as)((a) => if (f(a)) List(a) else Nil)
}

object E3_22 {
  def plus(a1: List[Int], a2: List[Int]): List[Int] = (a1, a2) match {
    case (h1::t1, h2::t2) => (h1+h2)::plus(t1,t2)
    case (_, _) => Nil
  }
}

object E3_23 {
  def zipWith[A,B,C](as: List[A], bs: List[B])(f: (A,B) => C): List[C] =
    (as, bs) match {
      case (h1::t1, h2::t2) => f(h1,h2)::zipWith(t1,t2)(f)
      case (_, _) => Nil
    }
}

object E3_24 {
  def hasSubsequence[A](sup: List[A], sub: List[A]): Boolean = {
    println("TODO")
    true
  }
}

object E3_25to29 {
  sealed trait Tree[+A]
  case class Leaf[A](value: A) extends Tree[A]
  case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]

  val sample = Branch(Branch(Leaf(1), Branch(Leaf(2), Leaf(3))), Leaf(4))

  def size[A](tree: Tree[A]): Int = tree match {
    case Leaf(_) => 1
    case Branch(left, right) => 1 + size(left) + size(right)
  }

  def maximum(tree: Tree[Int]): Int = tree match {
    case Leaf(n) => n
    case Branch(lhs, rhs) => maximum(lhs).max(maximum(rhs))
  }

  def depth[A](tree: Tree[Int]): Int = tree match {
    case Leaf(_) => 1
    case Branch(lhs, rhs) => 1+ depth(lhs).max(depth(rhs))
  }

  def map[A,B](tree: Tree[A])(f: A => B): Tree[B] = tree match {
    case Leaf(v) => Leaf(f(v))
    case Branch(lhs, rhs) => Branch(map(lhs)(f), map(rhs)(f))
  }

  // TODO: compare with list fold function
  def fold[A,B](tree: Tree[A])(f: A => B)(g: (B,B) => B): B = tree match {
    case Leaf(v) => f(v)
    case Branch(lhs, rhs) => g(fold(lhs)(f)(g), fold(rhs)(f)(g))
  }

  def sizef[A](tree: Tree[A]): Int = fold(tree)((_) => 1)(1+_+_)

  def maximumf(tree: Tree[Int]): Int = fold(tree)(identity)(_.max(_))

  def depthf[A](tree: Tree[A]): Int = fold(tree)((_) => 1)(1+_.max(_))

  // --From FunctionalProgrammingInScala source code:
  // Note the type annotation required on the expression `Leaf(f(a))`. Without
  // this annotation, we get an error like this: 
  //     type mismatch; found   : fpinscala.datastructures.Branch[B] required:
  //     fpinscala.datastructures.Leaf[B] fold(t)(a => Leaf(f(a)))(Branch(_,_)) ^  
  // This error is an unfortunate consequence of Scala using subtyping to
  // encode algebraic data types. Without the annotation, the result type of
  // the fold gets inferred as `Leaf[B]` and it is then expected that the
  // second argument to `fold` will return `Leaf[B]`, which it doesn't (it
  // returns `Branch[B]`). Really, we'd prefer Scala to infer `Tree[B]` as the
  // result type in both cases. When working with algebraic data types in
  // Scala, it's somewhat common to define helper functions that simply call
  // the corresponding data constructors but give the less specific result
  // type:
  def mapf[A,B](tree: Tree[A])(f: A => B): Tree[B] =
    fold(tree)(a => Leaf(f(a)): Tree[B])(Branch(_,_))
}

object E4_1 {
  sealed trait Option[+A] {
    def map[B](f: A => B): Option[B] = this match {
      case None => None
      case Some(v) => Some(f(v))
    }

    def flatMap[B](f: A => Option[B]): Option[B] = this match {
      case None => None
      case Some(v) => f(v)
    }

    def getOrElse[B >: A](default: => B): B = this match {
      case None => default
      case Some(v) => v
    }

    def orElse[B >: A](ob: => Option[B]): Option[B] = this match {
      case None => ob
      case Some(_) => this
    }

    def filter(f: A => Boolean): Option[A] = this match {
      case None => None
      case Some(v) => if (f(v)) this else None
    }
  }

  case class Some[+A](get: A) extends Option[A]
  case object None extends Option[Nothing]
}

object E4_2 {
  def variance(xs: Seq[Double]): Option[Double] = {
    if (xs.isEmpty) return None

    val mean = xs.sum / xs.size
    val seq = xs.map((x) => math.pow(x - mean, 2))
    Some(seq.sum / seq.size)
  }
}

object E4_3 {
  def map2[A,B,C](a: Option[A], b: Option[B])(f: (A,B) => C): Option[C] =
    (a,b) match {
      case (Some(a), Some(b)) => Some(f(a,b))
      case (_, _) => None
    }
}

object E4_4 {
  def sequence[A](as: List[Option[A]]): Option[List[A]] = {
    def f(b: List[A], a: Option[A]): List[A] = a match {
      case None => b
      case Some(v) => v :: b
    }
    val as2 = as.foldLeft(Nil: List[A])(f).reverse
    if (as2.size == as.size) Some(as2) else None
  }
}

object E4_5 {
  def traverse[A,B](as: List[A])(f: A => Option[B]): Option[List[B]] = {
    None // TODO
  }
}

object E4_6 {
  sealed trait Either[+E,+A] {
    def map[B](f: A => B): Either[E,B] = this match {
      case Right(v) => Right(f(v))
      case Left(v) => Left(v)
    }

    def flatMap[EE >: E, B](f: A => Either[EE,B]): Either[EE, B] = this match {
      case Right(v) => f(v)
      case Left(v) => Left(v)
    }

    def orElse[EE >: E, B >: A](b: => Either[EE,B]): Either[EE, B] = this match {
      case Right(v) => this
      case Left(_) => b
    }

    def map2[EE >: E, B, C](b: Either[EE, B])(f: (A,B) => C): Either[EE, C] =
      for {
        a0 <- this
        b0 <- b
      } yield f(a0, b0)
  }

  case class Left[+E](value: E) extends Either[E, Nothing]
  case class Right[+A](value: A) extends Either[Nothing, A]
}

object E4_7 {
  // TODO
}

object E4_8 {
  case class Person(name: Name, age: Age)
  sealed class Name(val value: String)
  sealed class Age(val value: Int)

  def mkName(name: String): Either[String, Name] =
    if (name == null || name.isEmpty) Left("Name is empty")
    else Right(new Name(name))

  def mkAge(age: Int): Either[String, Age] =
    if (age < 0) Left("Age is out of range") else Right(new Age(age))

  def mkPerson(name: String, age: Int): Either[List[String], Person] = {
    val n = mkName(name)
    val a = mkAge(age)
    val errs = List(n, a).collect{ case Left(err) => err }
    if (errs.isEmpty) Right(Person(n.right.get, a.right.get)) else Left(errs)
  }
}

object Main extends App {
  def pprint[A,B](a: A)(f: A => B): Unit = {
    println(a.getClass.getName + ": " + f(a))
  }

  pprint(E2_1)(_.fib(10))
  pprint(E2_2)(_.isSorted(Array(1, 2, 3))(_ < _))
  pprint(E2_3)(_.curry((a:Int,b:Int) => a < b)(1)(2))
  pprint(E2_4)(_.uncurry((a:Int) => (b:Int) => a < b)(1,2))
  pprint(E2_5)(_.compose((b:Int) => b+2, (a:String) => a.size)("hey"))
  pprint(E3_3)(_.setHead(0, List(1,2,3)))
  pprint(E3_4)(_.drop(List(1,2,3), 2))
  pprint(E3_5)(_.dropWhile(List(1,2,3,4,5), (n:Int) => n < 3))
  pprint(E3_6)(_.init(List(1,2,3,4,5)))
  pprint(E3_8)(_.demo)
  pprint(E3_9)(_.length(List(4,6,5)))
  pprint(E3_10)(_.foldLeft(List(4,6,5), 0)((b,a) => b+a))
  pprint(E3_11)(_.sum(List(4,6,5)))
  pprint(E3_11)(_.product(List(4,6,5)))
  pprint(E3_11)(_.length(List(4,6,5)))
  pprint(E3_12)(_.reverse(List(4,6,5)))
  pprint(E3_14)(_.appendl(List(1,2,3), List(4,6,5)))
  pprint(E3_14)(_.appendr(List(1,2,3), List(4,6,5)))
  pprint(E3_15)(_.concat(List(List(1), List(2,5), List(3), List(4))))
  pprint(E3_16)(_.add1(List(1,2,3)))
  pprint(E3_17)(_.toStringList(List(1,2,3)))
  pprint(E3_18)(_.mapl(List(1,2,3))(_+1))
  pprint(E3_18)(_.mapr(List(1,2,3))(_+1))
  pprint(E3_19)(_.filter(List(1,2,3,4))(_ % 2 == 0))
  pprint(E3_20)(_.flatMap(List(1,2,3))((a) => List(a,a)))
  pprint(E3_21)(_.filter(List(1,2,3,4))(_ % 2 == 0))
  pprint(E3_22)(_.plus(List(1,2,3), List(4,5,6)))
  pprint(E3_23)(_.zipWith(List('a', 'b', 'c'), List(4,5,6))((_,_)))
  pprint(E3_25to29)(_.size(E3_25to29.sample))
  pprint(E3_25to29)(_.maximum(E3_25to29.sample))
  pprint(E3_25to29)(_.depth(E3_25to29.sample))
  pprint(E3_25to29)(_.map(E3_25to29.sample)(_*10))
  pprint(E3_25to29)(_.sizef(E3_25to29.sample))
  pprint(E3_25to29)(_.maximumf(E3_25to29.sample))
  pprint(E3_25to29)(_.depthf(E3_25to29.sample))
  pprint(E3_25to29)(_.mapf(E3_25to29.sample)(_*10))
  pprint(E4_4)(_.sequence(List(Some(1), Some(2), Some(3))))
  pprint(E4_4)(_.sequence(List(Some(1), None, Some(3))))
}
