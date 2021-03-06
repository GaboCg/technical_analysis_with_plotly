#'---
#'author: Gabriel Cabrera G.
#'title: Technical Analysis using plotly
#'date: `r sys.Date()`
#'---

# cargamos librerias
if(!require("pacman")) install.packages("pacman")
p_load("plotly", "quantmod")

# descargamos data 
getSymbols("AMZN", src = 'yahoo', from = "2010-01-01", periodicity = "daily")

# creamos data frame
amazon <- data.frame(date = index(AMZN), coredata(AMZN))

# creamos las bandas de bollinger 
bbands <- data.frame(BBands(HLC(AMZN))) %>% 
          na.omit() %>% 
          select(dn, mavg, up)

amazon <- amazon %>% 
          filter(date >= as.Date(rownames(bbands)[1]))

df <- cbind(amazon,bbands)


for (i in 1:nrow(df)){
  if (df$AMZN.Close[i] >= df$AMZN.Open[i]) {
    
    df$direction[i] = "Aumento"
  
    } else {
      
    df$direction[i] = "Disminución"
  }
}

i <- list(line = list(color = '#17BECF'))
d <- list(line = list(color = '#7F7F7F'))


p <- df %>%
     plot_ly(x = ~date, type="candlestick", open = ~AMZN.Open, close = ~AMZN.Close,
             high = ~AMZN.High, low = ~AMZN.Low, name = "AMZN",
             increasing = i, decreasing = d) %>%
     add_lines(x = ~date, y = ~up , name = "B Bands",line = list(color = '#ccc', width = 0.5),
               legendgroup = "Bollinger Bands", hoverinfo = "none", inherit = F) %>%
     add_lines(x = ~date, y = ~dn, name = "B Bands", line = list(color = '#ccc', width = 0.5),
               legendgroup = "Bollinger Bands", inherit = F, showlegend = FALSE, hoverinfo = "none") %>%
     add_lines(x = ~date, y = ~mavg, name = "Mv Avg", line = list(color = '#E377C2', width = 0.5),
               hoverinfo = "none", inherit = F) %>%
     layout(yaxis = list(title = "Precio"))

pp <- df %>%
      plot_ly(x = ~date, y = ~AMZN.Volume, type='bar', name = "AMZN Volumen",
        color = ~ direction, colors = c('#17BECF','#7F7F7F')) %>%
      layout(yaxis = list(title = "Volume"))
      
rs <- list(visible = TRUE, x = 0.5, y = -0.055, xanchor = 'center', yref = 'paper',
          font = list(size = 9),
          buttons = list(
            list(count=1,
              label='RESET',
              step='all'),
            list(count=1,
              label='1 YR',
              step='year',
              stepmode='backward'),
            list(count=3,
              label='3 MO',
              step='month',
              stepmode='backward'),
            list(count=1,
              label='1 MO',
              step='month',
              stepmode='backward')
          ))

ppp <- subplot(p, pp, heights = c(0.7,0.2), nrows=2, shareX = TRUE, titleY = TRUE) %>%
               layout(title = paste("S&P 500: 2015-01-01",Sys.Date()), xaxis = list(rangeselector = rs),
               legend = list(orientation = 'h', x = 0.5, y = 1, xanchor = 'center', yref = 'paper',
               font = list(size = 10),
               bgcolor = 'transparent'))

ppp
