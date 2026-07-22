#!/bin/bash
# DummyC インクリメント・複合代入テスト
# 使い方: dummyc-lab で bash test_incdec.sh

PASS=0
FAIL=0

run() {
  local name="$1"
  local src="$2"
  local want="$3"
  printf '%s' "$src" > id_tmp.dc
  rm -f id_tmp.ll
  ./dcc id_tmp.dc > /dev/null 2>&1
  if [ ! -f id_tmp.ll ]; then
    printf '  FAIL  %-28s (compile error)\n' "$name"
    FAIL=$((FAIL+1))
    return
  fi
  lli id_tmp.ll > /dev/null 2>&1
  local got=$?
  if [ "$got" = "$want" ]; then
    printf '  ok    %-28s %s\n' "$name" "$got"
    PASS=$((PASS+1))
  else
    printf '  FAIL  %-28s got %s, want %s\n' "$name" "$got" "$want"
    FAIL=$((FAIL+1))
  fi
}

echo "=== インクリメント ==="
run "i++"            'int main(){ int i; i = 41; i++; return i; }' 42
run "i++ twice"      'int main(){ int i; i = 40; i++; i++; return i; }' 42
run "i++ from zero"  'int main(){ int i; i = 0; i++; return i; }' 1
run "i++ in loop"    'int main(){ int i; int c; c = 0; for(i = 0; i < 42; i++){ c++; } return c; }' 42

echo ""
echo "=== デクリメント ==="
run "i--"            'int main(){ int i; i = 43; i--; return i; }' 42
run "i-- twice"      'int main(){ int i; i = 44; i--; i--; return i; }' 42
run "i-- to zero"    'int main(){ int i; i = 1; i--; return i; }' 0
run "i-- in while"   'int main(){ int i; i = 50; while(i > 42){ i--; } return i; }' 42

echo ""
echo "=== 複合代入 ==="
run "+="             'int main(){ int i; i = 40; i += 2; return i; }' 42
run "-="             'int main(){ int i; i = 50; i -= 8; return i; }' 42
run "*="             'int main(){ int i; i = 6; i *= 7; return i; }' 42
run "/="             'int main(){ int i; i = 84; i /= 2; return i; }' 42
run "%="             'int main(){ int i; i = 17; i %= 5; return i; }' 2
run "+= expr"        'int main(){ int i; i = 20; i += 20 + 2; return i; }' 42
run "*= expr"        'int main(){ int i; i = 3; i *= 2 * 7; return i; }' 42
run "chained +="     'int main(){ int i; i = 0; i += 10; i += 12; i += 20; return i; }' 42

echo ""
echo "=== for 文での使用 ==="
run "for i++"        'int main(){ int i; int s; s = 0; for(i = 0; i < 10; i++){ s += i; } return s; }' 45
run "for i += 1"     'int main(){ int i; int s; s = 0; for(i = 0; i < 10; i += 1){ s += i; } return s; }' 45
run "for i += 2"     'int main(){ int i; int s; s = 0; for(i = 0; i < 10; i += 2){ s += i; } return s; }' 20
run "for i--"        'int main(){ int i; int c; c = 0; for(i = 10; i > 0; i--){ c++; } return c; }' 10
run "nested for"     'int main(){ int i; int j; int c; c = 0; for(i = 0; i < 6; i++){ for(j = 0; j < 7; j++){ c++; } } return c; }' 42

echo ""
echo "=== 配列と組み合わせ ==="
run "array += "      'int main(){ int a[5]; a[0] = 40; a[0] += 2; return a[0]; }' 42
run "array sum"      'int main(){ int a[5]; int i; int s; for(i = 0; i < 5; i++){ a[i] = i; } s = 0; for(i = 0; i < 5; i++){ s += a[i]; } return s; }' 10
run "2d array +="    'int main(){ int a[3][3]; a[1][1] = 40; a[1][1] += 2; return a[1][1]; }' 42
run "2d fill sum"    'int main(){ int a[3][4]; int i; int j; int s; for(i = 0; i < 3; i++){ for(j = 0; j < 4; j++){ a[i][j] = i * 4 + j; } } s = 0; for(i = 0; i < 3; i++){ for(j = 0; j < 4; j++){ s += a[i][j]; } } return s; }' 66

echo ""
echo "=== 構造体と組み合わせ ==="
run "member +="      'class P { int x; } int main(){ P p; p.x = 40; p.x += 2; return p.x; }' 42
run "member array"   'class T { int a[4]; } int main(){ T t; int i; int s; for(i = 0; i < 4; i++){ t.a[i] = i; } s = 0; for(i = 0; i < 4; i++){ s += t.a[i]; } return s; }' 6

echo ""
echo "=== 既存機能との共存 ==="
run "plus still ok"  'int main(){ return 20 + 22; }' 42
run "minus still ok" 'int main(){ return 50 - 8; }' 42
run "assign still ok" 'int main(){ int i; i = 42; return i; }' 42
run "comment ok"     'int main(){ /* c */ int i; i = 41; i++; return i; }' 42
run "line comment"   'int main(){ // c
  int i; i = 41; i++; return i; }' 42
run "div still ok"   'int main(){ return 84 / 2; }' 42

rm -f id_tmp.dc id_tmp.ll
echo ""
echo "=============================="
printf "  pass: %d   fail: %d\n" "$PASS" "$FAIL"
echo "=============================="
