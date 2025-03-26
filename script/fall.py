# https://mslc.ctf.su/wp/polictf-2012-crypto-500/
# https://ctftime.org/writeup/29700
# https://giacomopope.com/hsctf-2019/#spooky-ecc

p = 4007911249843509079694969957202343357280666055654537667969
q = 2*p + 1
a = 479674765111403080798288599752794621357071126054239970719 
b = 1839890679886286542886449861618094502587090720247817035647

Ep = EllipticCurve(GF(p), [a,b])
G = Ep(741691539696267564005241324344676638704819822626281227364,3102360199939373249439960210926161310269296148717758328237)
Q = Ep(228372021298333142209829245091882548944496316312635232236,3693481507636668030082911526987394375826206080991036294396)

n = Ep.order()
Fn = FiniteField(n)

m = 19666107331951626476415026567086342074650612991336538073686539593437448590271

def SmartAttack(P,Q,p):
    E = P.curve()
    Eqp = EllipticCurve(Qp(p, 2), [ ZZ(t) + randint(0,p)*p for t in E.a_invariants() ])

    P_Qps = Eqp.lift_x(ZZ(P.xy()[0]), all=True)
    for P_Qp in P_Qps:
        if GF(p)(P_Qp.xy()[1]) == P.xy()[1]:
            break

    Q_Qps = Eqp.lift_x(ZZ(Q.xy()[0]), all=True)
    for Q_Qp in Q_Qps:
        if GF(p)(Q_Qp.xy()[1]) == Q.xy()[1]:
            break

    p_times_P = p*P_Qp
    p_times_Q = p*Q_Qp

    x_P,y_P = p_times_P.xy()
    x_Q,y_Q = p_times_Q.xy()

    phi_P = -(x_P/y_P)
    phi_Q = -(x_Q/y_Q)
    k = phi_Q/phi_P
    return ZZ(k)

def ecdsa_sign(d, m):
  r = 0
  s = 0
  while s == 0:
    k = 1
    while r == 0:
      k = randint(1, n - 1)
      Q = k * G
      (x1, y1) = Q.xy()
      r = Fn(x1)
    e = m
    s = Fn(k) ^ (-1) * (e + d * r)
  return [r, s]

def ecdsa_verify(Q, m, r, s):
  e = m
  w = s ^ (-1)
  u1 = (e * w)
  u2 = (r * w)
  P1 = Integer(u1) * G
  P2 = Integer(u2) * Q
  X = P1 + P2
  (x, y) = X.xy()
  v = Fn(x)
  return v == r

d = SmartAttack(G,Q,p)

[r, s] = ecdsa_sign(d, m)
result = ecdsa_verify(Q, m, r, s)

print (f"Message: {m}")
print (f"Public Key: {Q.xy()}")
print (f"Private Key: {d}")

print ("=== Signature ===")
print (f" r = {r}")
print (f" s = {s}")
print (f"Verification: {result}")

# Message: 19666107331951626476415026567086342074650612991336538073686539593437448590271
# Public Key: (228372021298333142209829245091882548944496316312635232236, 3693481507636668030082911526987394375826206080991036294396)
# Private Key: 2590225047465443722024386469461634294729219346156883417670
# === Signature ===
#  r = 2195097151127120065579326181785367043581509779126357541128
#  s = 928540552076520879873320608471470817377985074596666122262
# Verification: True