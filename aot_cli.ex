list = [1, 2, 3]
fn_hd = hd(list)
fn_tl = tl(list)
[match_hd | match_tl] = list
IO.puts(to_string(fn_hd) <> " " <> to_string(fn_tl))
exit(:normal)
IO.puts(to_string(match_hd) <> " " <> to_string(match_tl))