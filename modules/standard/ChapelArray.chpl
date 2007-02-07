def _build_domain_type(dist, param rank : int, type dimensional_index_type = int) {
  var x = dist.buildDomain(rank, dimensional_index_type);
  return _domain(x.type, x.getValue(x.getHeadCursor()).type, dimensional_index_type, rank, x);
}

def _build_domain_type(dist, type ind_type) {
  var x = dist.buildDomain(ind_type);
  return _domain(x.type, ind_type, ind_type, 1, x);
}


def _build_subdomain_type(dom)
  return dom.buildSubdomain();

def _build_sparse_domain_type(dom)
  return dom.buildSparseDomain();

def _build_array_type(dom, type eltType)
  return dom.buildArray(eltType);

def _build_domain(x)
  return x;

def _build_domain(ranges: _aseq ...?rank) {
  type t = ranges(1).eltType;
  var x = SingleLocaleArithmeticDomain(rank, t, ranges);
  return _domain(x.type, x.getValue(x.getHeadCursor()).type, t, rank, x);
}

def _build_exclusive_upper_domain(x: _domain)
  return x.buildExclusiveUpperDomain();

def _build_index_type(param i: int) where i > 1 {
  var x : i*int;
  return x;
}

def _build_index_type(param i: int) where i == 1 {
  var x : int;
  return x;
}

def _build_index_type(dom) {
  var x: dom._index_type;
  return x;
}

pragma "domain"
class _domain {
  type _domain_type;
  type _index_type;
  type _dim_index_type;
  param rank : int;
  var _value : _domain_type;
  var _arrs: seq(BaseArray);

  def getHeadCursor()
    return _value.getHeadCursor();

  def getNextCursor(c)
    return _value.getNextCursor(c);

  def getValue(c)
    return _value.getValue(c);

  def isValidCursor?(c)
    return _value.isValidCursor?(c);

  iterator this() : _index_type {
    forall x in _value
      yield x; 
  }

  def this(dim : int)
    return _value(dim);

  def buildArray(type eltType) {
    var x = _value.buildArray(eltType);
    _arrs #= x;
    return _array(x.type, eltType, rank, x, this);
  }

  def buildSparseDomain() {
    var x = _value.buildSparseDomain();
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def buildSubdomain() {
    var x = _value.buildSubdomain();
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def buildExclusiveUpperDomain()
    return _domain(_domain_type, _index_type, _dim_index_type, rank, _value.buildExclusiveUpperDomain());

  def add(i) {
    _value.add(i);
  }

  def remove(i) {
    _value.remove(i);
  }

  def numIndices return _value.numIndices;
  def low return _value.low;
  def high return _value.high;

  def member?(i) {
    return _value.member?(i);
  }

  def expand(i: int ...rank)
    return expand(i);

  def expand(i: rank*int) {
    var x = _value.expand(i);
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def expand(i: int) where rank > 1 {
    var x = _value.expand(i);
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def exterior(i: int ...rank)
    return exterior(i);

  def exterior(i: rank*int) {
    var x = _value.exterior(i);
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def interior(i: int ...rank)
    return interior(i);

  def interior(i: rank*int) {
    var x = _value.interior(i);
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  def translate(i: int ...rank)
    return translate(i);

  def translate(i: rank*int) {
    var x = _value.translate(i);
    return _domain(x.type, _index_type, _dim_index_type, rank, x);
  }

  iterator subBlocks {
    for d in _value.subBlocks do
      yield d;
  }
}

def =(a: _domain, b: _domain) {
  if a == nil then return b; // stopgap: why? --sjd
  for e in a._arrs do
    e.reallocate(b);
  a._value = b._value;
  return a;
}

def _domain.writeThis(f: Writer) {
  f.write(_value);
}

def by(a: _domain, b) {
  var x = a._value by b;
  return _domain(x.type, a._index_type, a._dim_index_type, a.rank, x);
}

// this is a wrapper class for all arrays
pragma "array"
class _array {
  type _array_type;
  type eltType;
  param rank : int;
  var _value : _array_type;
  var dom : _domain;

  def this(d: _domain) {
    var x = _value.slice(d._value);
    return _array(x.type, eltType, rank, x, d);
  }

  def this(i: _aseq(dom._dim_index_type) ...rank) {
    var d = [(...i)];
    return this(d);
  }

  def =this(d: _domain, val) {
    var y = _array(_array_type, eltType, rank, dom=d);
    y._value = _value.slice(d._value);
    y = val;
  }

  def =this(d: _domain, val: eltType) {
    var y = _array(_array_type, eltType, rank, dom=d);
    y._value = _value.slice(d._value);
    y = val;
  }

  def =this(i: _aseq(dom._dim_index_type) ...rank, val) where rank > 0 {
    var d = [(...i)];
    var y = _array(_array_type, eltType, rank, dom=d);
    y._value = _value.slice(d._value);
    y = val;
  }

  def =this(i: _aseq(dom._dim_index_type) ...rank, val: eltType) where rank > 0 {
    var d = [(...i)];
    var y = _array(_array_type, eltType, rank, dom=d);
    y._value = _value.slice(d._value);
    y = val;
  }

  def this(i: dom._index_type)
    return _value(i);

  def this(i: dom._dim_index_type ...rank) where rank > 1
    return _value(i);

  def =this(i: dom._index_type, val: eltType) {
    _value(i) = val;
  }

  def =this(i: dom._dim_index_type ...rank, val: eltType) where rank > 1 {
    _value(i) = val;
  }

  def getHeadCursor()
    return _value.getHeadCursor();

  def getNextCursor(c)
    return _value.getNextCursor(c);

  def getValue(c)
    return _value.getValue(c);

  def isValidCursor?(c)
    return _value.isValidCursor?(c);

  iterator this() : eltType {
    forall x in _value
      yield x; 
  }

  def numElements return dom.numIndices;

  def view(d: _domain) {
    var x = _value.view(d._value);
    return _array(x.type, eltType, rank, x, d);
  }
}

def =(a: _array, b: _array) {
  a._value.assign(b._value);
  return a;
}

def =(a: _array, b: _domain) {
  a._value.assign(b._value);
  return a;
}

def =(a: _array, b) {
  a._value.assign(b);
  return a;
}

def =(a: _array, b: a.eltType) {
  a._value.assign(b);
  return a;
}

def _copy(a: _array) {
  if a._value == nil then return a;
  var b : [a.dom] a.eltType;
  b = a;
  return b;
}

def _pass(a: _array) {
  return a;
}

def _init(a: _array) {
  var b : [a.dom] a.eltType;
  return b;
}

def _array.writeThis(f: Writer) {
  f.write(_value);
}

// this is the class that all array classes are derived from
pragma "BaseArray"
class BaseArray {
  def reallocate(d: _domain) {
    halt("reallocating not support for this array type");
  }

  def purge( ind: int) {
    halt("purging not supported for this array type");
  }

  def _resize( length: int, old_map: _ddata(int)) {
    halt("resizing not supported for this array type");
  }
}

class BaseDomain { }
