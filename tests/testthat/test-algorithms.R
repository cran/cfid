# ID* and IDC*

g1 <- dag("X -> W -> Y <- Z <- D X <-> Y")
g2 <- dag("X -> W -> Y <- Z <- D X <-> Y X -> Y")
g3 <- dag("X -> Y <-> A <-> B <-> Z <- X")

v1 <- cf("Y", 0, c(X = 0))
v2 <- cf("X", 1)
v3 <- cf("Z", 0, c(D = 0))
v4 <- cf("D", 0)
v5 <- cf("Y", 0, c(X = 0, Z = 0))
v6 <- cf("Z", 1, c(X = 0))
v7 <- cf("Y", 0, c(Y = 1))
v8 <- cf("Y", 0, c(Y = 0))
v9 <- cf("A", 0)
v10 <- cf("B", 0)
v11 <- cf("Z", 0, c(X = 1))
c1 <- conj(v1, v2, v3, v4)

test_that("identifiable conjunction", {
    out <- identifiable(g1, c1)
    expect_true(out$id)
})

test_that("non-identifiable conjunction", {
    out <- identifiable(g2, c1)
    expect_false(out$id)
})

test_that("identifiable conditional conjunction", {
    out <- identifiable(g1, conj(v1), conj(v2, v3, v4))
    expect_true(out$id)
})

test_that("non-identifiable conditional conjunction", {
    out <- identifiable(g2, conj(v3), c1)
    expect_false(out$id)
})

test_that("undefined conditional conjunction", {
    out <- identifiable(g1, conj(v1), conj(v7))
    expect_true(out$undefined)
})

test_that("joint gamma/delta inconsistent", {
    out <- identifiable(g1, conj(v1, v2, v3), conj(v4, v5, v6))
    expect_equal(out$prob$val, 0L)
})

test_that("incompatible interventions", {
    out <- identifiable(g3, conj(v1, v9, v10, v11))
    expect_false(out$id)
})

test_that("tautology", {
    out <- identifiable(g1, conj(v8))
    expect_true(out$id)
    expect_equal(out$prob$val, 1L)
})

test_that("inconsistent", {
    out <- identifiable(g1, conj(v7))
    expect_true(out$id)
    expect_equal(out$prob$val, 0L)
})

test_that("remove tautology", {
    out <- identifiable(g1, conj(v1, v2, v3, v3, v8))
    expect_true(out$id)
})

test_that("auto convert singletons", {
    out1 <- identifiable(g1, v1)
    out2 <- identifiable(g1, conj(v1))
    expect_identical(out1, out2)
})

# Interface

test_that("valid input", {
    expect_error(identifiable())
    expect_error(identifiable(c1))
    expect_error(identifiable(g1))
    expect_error(identifiable(g1, g1))
    expect_error(identifiable(g1, c1, g1))
})
