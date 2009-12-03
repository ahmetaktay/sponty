function probabilities=computeBigram(history)
  n = length(history.isTarget);
  correct = history.correct;
  target = history.isTarget;
  cc = 0;
  ci = 0;
  ic = 0;
  ii = 0;
  pre = 1;
  while pre < n - 1
    post = pre + 1;
    if target(pre) && target(post)
      if correct(pre)
        if correct(post)
          cc = cc + 1;
        else
          ci = ci + 1;
        end
      else
        if correct(post)
          ic = ic + 1;
        else
          ii = ii + 1;
        end
      end
    end
    pre = pre + 1;
  end
  cc
  ci
  ic
  ii
  
