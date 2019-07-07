context('Data import functions')

test_that('get_FRED() works', {
    # 'Default' FRED ID
    df_MONAN <- get_FRED('MONAN')

    expect_gt(nrow(df_MONAN), 0)
    expect_equal(colnames(df_MONAN), c('DATE', 'MONAN'))

    # Different FRED ID
    df_GDP <- get_FRED('GDP')

    expect_gt(nrow(df_GDP), 0)
    expect_equal(colnames(df_GDP), c('DATE', 'GDP'))
})
