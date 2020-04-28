#!/usr/bin/ruby
# -*- coding: UTF-8 -*-

require "stringio"

$nofVar = 0;
$nofClause = 0;
$sumOfWeights = 0;
$ipFormStr = String.new();
$satFormStr = String.new();

def reset()
  $nofVar = 0;
  $nofClause = 0;
  $sumOfWeights = 0;
  $ipFormStr.clear();
  $satFormStr.clear();
end

def totalizer(hash)
  if hash.size == 1
    #puts "weight = #{hash[hash.keys[0]]}";
    return Array.new((1..hash[hash.keys[0]]).to_a).map{
      hash.keys[0]
    };
  else
    sumOfZUnary = hash.values.sum;
    sizofLeft = (hash.size/2).floor;

    lHash = Hash.new();
    while lHash.size < sizofLeft
      tmpArr = Array.new(hash.shift);
      lHash.store(tmpArr[0], tmpArr[1]);
    end
    
    xUnary = totalizer(lHash);
    yUnary = totalizer(hash);
    zUnary = Array.new((1..sumOfZUnary).to_a).map{
      newVarID()
    };
    
    bufferArray = Array.new();
    for i in 0..xUnary.size
      for j in 0..yUnary.size
        if i != 0 && j != 0
          bufferArray.push("#{$sumOfWeights+1} #{-1 * xUnary[i-1]} #{-1 * yUnary[j-1]} #{zUnary[i+j-1]} 0\n");
          $nofClause += 1;
        end
        if i == 0 && j != 0
          bufferArray.push("#{$sumOfWeights+1} #{-1 * yUnary[j-1]} #{zUnary[j-1]} 0\n");
          $nofClause += 1;
        end
        if i != 0 && j == 0
          bufferArray.push("#{$sumOfWeights+1} #{-1 * xUnary[i-1]} #{zUnary[i-1]} 0\n");
          $nofClause += 1;
        end
      end
    end
    
    for i in 0..bufferArray.size-1
      $satFormStr << bufferArray[i];
    end
    bufferArray.clear;
    
    return zUnary;
  end
end

def gasDistrRnd(nofCell, expectV, stanDev, generatedRndArray)
  pi = 3.1415926535;
  if nofCell % 2 == 1
    nofCell += 1;
  end
  generatedRndArray.clear;
  for i in 1..(nofCell/2)
    x = rand;
    y = rand;
    z1 = stanDev * Math.sqrt(-2 * Math.log(x)) * Math.cos(2 * pi * y) + expectV;
    z2 = stanDev * Math.sqrt(-2 * Math.log(x)) * Math.sin(2 * pi * y) + expectV;
    generatedRndArray.push(z1.to_i == 0 ? 1 : z1.to_i);
    generatedRndArray.push(z2.to_i == 0 ? 1 : z2.to_i);
  end
end

def eucliDist(x1, y1, x2, y2)
  return Math.sqrt( (x1-x2)**2 + (y1-y2)**2 ).round;
end

def printMatx(arr)
  for i in 0..arr.size-1
    for j in 0..arr[i].size-1
      print "#{arr[i][j]}\t";
    end
    print "\n";
  end
  print "\n";
end

def costEst(filePath)
  weightMatx = Array.new();
  positionArr = Array.new();
  File.open(filePath, "r+"){|f| 
    f.each_with_index{|l, i|
      next if i == 0
      positionArr.push(l.split(" ").drop(1).map{|i| i.to_i});
      #positionArr.push(l.split(" ").drop(1).map{|i| (100*i.to_f).round});
    }
  }
  #p positionArr;
  for i in 0..positionArr.size-1
    tmpArr = Array.new();
    for j in 0..positionArr.size-1
      if i != j
        tmpArr.push(eucliDist(positionArr[i][0], positionArr[i][1], positionArr[j][0], positionArr[j][1]));
      else
        tmpArr.push(0);
      end
    end
    weightMatx.push(tmpArr);
  end
  return weightMatx;
end

def costEst100(filePath)
  weightMatx = Array.new();
  positionArr = Array.new();
  File.open(filePath, "r+"){|f| 
    f.each_with_index{|l, i|
      next if i == 0
      #positionArr.push(l.split(" ").drop(1).map{|i| i.to_i});
      positionArr.push(l.split(" ").drop(1).map{|i| (100*i.to_f).round});
    }
  }
  #p positionArr;
  for i in 0..positionArr.size-1
    tmpArr = Array.new();
    for j in 0..positionArr.size-1
      if i != j
        tmpArr.push(eucliDist(positionArr[i][0], positionArr[i][1], positionArr[j][0], positionArr[j][1]));
      else
        tmpArr.push(0);
      end
    end
    weightMatx.push(tmpArr);
  end
  return weightMatx;
end

def mapsToMatx(filePath)
  weightMatx = Array.new();
  File.open(filePath, "r+"){|f| 
    f.each_with_index{|l, i|
      next if i == 0
      weightMatx.push(l.split(" ").map{|i| i.to_i});
    }
  }
  return weightMatx;
end

def mapsToHalfMatx(filePath)
  weightMatx = Array.new();
  tmpArr = Array.new();
  tmpArr2 = Array.new();
  File.open(filePath, "r+"){|f| 
    f.each_with_index{|l, i|
      next if i == 0
      tmpArr.push(l.split(" ").map{|i| i.to_i});
    }
  }
  #p tmpArr;
  nofCity = tmpArr[0].size+1;
  for i in 0..nofCity-2
    tmpArr2.push(tmpArr[i].push(0));
    for j in 0..nofCity-1
      if j > nofCity-i-1
        tmpArr2[i].push(1);
      end
    end
  end
  tmpArr2.push(Array.new(nofCity-1, 1).unshift(0));
  for i in 0..nofCity-1
    tmpArr3 = Array.new();
    for j in 0..nofCity-1
      tmpArr3.push(tmpArr2[nofCity-1-j][i]);
    end
    weightMatx.push(tmpArr3);
  end
  for i in 0..nofCity-1
    for j in 0..nofCity-1
      if j < i
        weightMatx[i][j] = weightMatx[j][i];
      end
    end
  end
  return weightMatx;
end

def mapsTo2D(filePath, nofCity)
  weightMatx = Array.new();
  tmpArr = Array.new();
  File.open(filePath, "r+"){|f| 
    f.each_with_index{|l, i|
      next if i == 0
      tmpArr.push(l.split(" ").map{|i| i.to_i});
    }
  }
  tmpArr = tmpArr.to_s.delete("[").delete("]").delete(",").split(" ").map{|i| i.to_i};
  #p tmpArr;
  counter = -1;
  for i in 0..nofCity-1
    tmpArr2 = Array.new();
    for j in 0..nofCity-1
      if j < i
        loop do
          tmpInt = tmpArr[counter += 1];
          if tmpInt != 0
            tmpArr2.push(tmpInt);
            break;
          end
        end
      else
        tmpArr2.push(0);
      end
    end
    weightMatx.push(tmpArr2);
  end
  for i in 0..nofCity-1
    for j in 0..nofCity-1
      if j > i
        weightMatx[i][j] = weightMatx[j][i];
      end
    end
  end
  return weightMatx;
end

def newVarID()
  return $nofVar += 1;
end

def eqlOne(arr)
  $ipFormStr << "x#{arr[0]} ";
  for i in 1..arr.size-1
    $ipFormStr << "+ x#{arr[i]} ";
  end
  $ipFormStr << "= 1\n";
end

def twoEqlSums(arr1, arr2)
  $ipFormStr << "x#{arr1[0]} ";
  for i in 1..arr1.size-1
    $ipFormStr << "+ x#{arr1[i]} ";
  end
  for i in 0..arr2.size-1
    $ipFormStr << "- x#{arr2[i]} ";
  end
  $ipFormStr << "= 0\n";
end

def writeIP(fileName)
  mod = File.new(fileName, "w+");
  mod.syswrite("Enter example\n\nMinimize y\n\nSubject to\n" + $ipFormStr);
end

def atMostOne(arr)
  for i in 0..arr.size-1
    for j in i+1..arr.size-1
      $satFormStr << "#{$sumOfWeights+1} -#{arr[i]} -#{arr[j]} 0\n";
      $nofClause += 1;
    end
  end
end

def atLeastOne(arr)
  $satFormStr << "#{$sumOfWeights+1} ";
  for i in 0..arr.size-1
    $satFormStr << "#{arr[i]} ";
  end
  $satFormStr << "0\n";
  $nofClause += 1;
end

def twoSumsEqvt(arr1, arr2)
  for i in 0..arr1.size-1
    $satFormStr << "#{$sumOfWeights+1} -#{arr1[i]} ";
    for j in 0..arr2.size-1
      $satFormStr << "#{arr2[j]} ";
    end
    $satFormStr << "0\n";
    $nofClause += 1;
  end
  for i in 0..arr2.size-1
    $satFormStr << "#{$sumOfWeights+1} -#{arr2[i]} ";
    for j in 0..arr1.size-1
      $satFormStr << "#{arr1[j]} ";
    end
    $satFormStr << "0\n";
    $nofClause += 1;
  end
end

def writeSAT(fileName)
  wcnf = File.new(fileName, "w+");
  wcnf.write("p wcnf #{$nofVar} #{$nofClause} #{$sumOfWeights+1}\n" + $satFormStr);
end

def insGen(fileName, nofSManStr)
  nofCity = "#{fileName[0, fileName.size-4].match(/\d+/)}".to_i;
  nofSMan = "#{nofSManStr.match(/\d+/)}".to_i;
  weighType = "#{File.open(fileName, &:readline).match(/\d/)}".to_i;

  puts "file=#{fileName}; nofCity=#{nofCity}; nofSMan=#{nofSMan}; weighType=#{weighType}.";

  tmpArr = Array.new();
  tmpArr2 = Array.new();
  
  pMatx = Array.new((0..nofSMan-1).to_a).map{
    Array.new((0..nofCity-1).to_a).map{
      Array.new((1..nofCity).to_a).map{
        newVarID()
      }
    }
  };
  p pMatx;
  
  dMatx = Array.new((0..nofCity-3).to_a).map{
    Array.new((0..nofCity-2).to_a).map{
      Array.new((0..nofCity-2).to_a).map{
        newVarID();
      }
    }
  };
  for i in 0..nofCity-3
    puts "#{i+1}-th depth's cross section: \n";
    for j in 0..nofCity-2
      p dMatx[i][j];
    end
  end
  
=begin
  tmpArr.clear();
  gasDistrRnd(nofCity*(nofCity-1)/2, 6, 2, tmpArr);
  wMatx = Array.new((0..nofCity-1).to_a).map{|i| 
    Array.new((0..nofCity-1).to_a).map{|j| 
      j > i ? tmpArr.shift() : 0
    } 
  };
  for i in 0..nofCity-1
    for j in 0..nofCity-1
      if j < i
        wMatx[i][j] = wMatx[j][i];
      end
    end
  end
=end
  case weighType
  when 1 then
    wMatx = costEst(fileName);
  when 2 then
    wMatx = costEst100(fileName);
  when 3 then
    wMatx = mapsToMatx(fileName);
  when 4 then
    wMatx = mapsToHalfMatx(fileName);
  when 5 then
    wMatx = mapsTo2D(fileName, nofCity);
  end
  #wMatx = mapsToMatx(fileName);
  #wMatx = mapsToHalfMatx(fileName);
  #wMatx = costEst(fileName);
  #wMatx = mapsTo2D(fileName, nofCity);
  
  $sumOfWeights = wMatx.map{|i| 
    i.sum()
  }.sum();
  
  ## IP start ->
  # Eq.2
  for i in 0..nofSMan-1
    tmpArr.clear();
    for j in 1..nofCity-1
      tmpArr.push(pMatx[i][0][j]);
    end
    eqlOne(tmpArr);
  end
  
  # Eq.3
  for i in 0..nofSMan-1
    tmpArr.clear();
    for j in 1..nofCity-1
      tmpArr.push(pMatx[i][j][0]);
    end
    eqlOne(tmpArr);
  end
  
  # Eq.4
  for i in 1..nofCity-1
    tmpArr.clear();
    for j in 0..nofSMan-1
      for k in 0..nofCity-1
        if k != i
          tmpArr.push(pMatx[j][k][i]);
        end
      end
    end
    eqlOne(tmpArr);
  end
  
  # Eq.5
  for i in 1..nofCity-1
    tmpArr.clear();
    for j in 0..nofSMan-1
      for k in 0..nofCity-1
        if k != i
          tmpArr.push(pMatx[j][i][k]);
        end
      end
    end
    eqlOne(tmpArr);
  end
  
  # Eq.6
  for i in 0..nofSMan-1
    for j in 1..nofCity-1
      tmpArr.clear();
      tmpArr2.clear();
      for k in 0..nofCity-1
        if k != j
          tmpArr.push(pMatx[i][j][k]);
          tmpArr2.push(pMatx[i][k][j]);
        end
      end
      twoEqlSums(tmpArr, tmpArr2);
    end
  end
  
  # Eq.7 (MTZ formula)
  tmpInt = nofCity - nofSMan;
  for i in 1..nofCity-1
    for j in 1..nofCity-1
      if j != i
        $ipFormStr << "u#{i+1} - u#{j+1} ";
        for k in 0..nofSMan-1
          $ipFormStr << "+ #{tmpInt} x#{pMatx[k][i][j]} ";
        end
        $ipFormStr << "<= #{tmpInt-1}\n";
      end
    end
  end
  
  # Eq.8
  for i in 0..nofSMan-1
    for j in 0..nofCity-1
      for k in 0..nofCity-1
        if k != j
          if j == 0 && k == 1
            $ipFormStr << "#{wMatx[j][k]} x#{pMatx[i][j][k]} ";
          else
            $ipFormStr << "+ #{wMatx[j][k]} x#{pMatx[i][j][k]} ";
          end
        end
      end
    end
    $ipFormStr << "- y <= 0\n";
  end
  
  # Bounds
  $ipFormStr << "\nBounds\n";
  for i in 2..nofCity
    $ipFormStr << "0 < u#{i}\n";
  end
  
  # Binary
  $ipFormStr << "\nBinary\n";
  for i in 0..nofSMan-1
    for j in 0..nofCity-1
      for k in 0..nofCity-1
        if k != j
          $ipFormStr << "x#{pMatx[i][j][k]}\n";
        end
      end
    end
  end
  
  # Integer
  $ipFormStr << "\nGeneral\n";
  for i in 2..nofCity
    $ipFormStr << "u#{i}\n";
  end
  
  $ipFormStr << "End\n\nOptimize\n\nDisplay solution variables -\n\nQuit";
  
  #puts $ipFormStr;
  
  # write IP file
  writeIP(fileName[0, fileName.size-4] + "_m#{nofSMan}.lp");
  ## IP end <-
  
  ## SAT start ->
  # Eq.2
  for i in 0..nofSMan-1
    tmpArr.clear();
    for j in 1..nofCity-1
      tmpArr.push(pMatx[i][0][j]);
    end
    atMostOne(tmpArr);
    atLeastOne(tmpArr);
  end
  
  # Eq.3
  for i in 0..nofSMan-1
    tmpArr.clear();
    for j in 1..nofCity-1
      tmpArr.push(pMatx[i][j][0]);
    end
    atMostOne(tmpArr);
    atLeastOne(tmpArr);
  end
  
  # Eq.4
  for i in 1..nofCity-1
    tmpArr.clear();
    for j in 0..nofSMan-1
      for k in 0..nofCity-1
        if k != i
          tmpArr.push(pMatx[j][k][i]);
        end
      end
    end
    atMostOne(tmpArr);
    atLeastOne(tmpArr);
  end
  
  # Eq.5
  for i in 1..nofCity-1
    tmpArr.clear();
    for j in 0..nofSMan-1
      for k in 0..nofCity-1
        if k != i
          tmpArr.push(pMatx[j][i][k]);
        end
      end
    end
    atMostOne(tmpArr);
    atLeastOne(tmpArr);
  end
  
  # Eq.6
  for i in 0..nofSMan-1
    for j in 1..nofCity-1
      tmpArr.clear();
      tmpArr2.clear();
      for k in 0..nofCity-1
        if k != j
          tmpArr.push(pMatx[i][j][k]);
          tmpArr2.push(pMatx[i][k][j]);
        end
      end
      twoSumsEqvt(tmpArr, tmpArr2);
    end
  end
  
  # Eq.7 (MTZ formula)
  # implication between pMatx and dMatx
  for i in 0..nofSMan-1
    for j in 1..nofCity-1
      for k in 1..nofCity-1
        if k != j
          # from pMatx tp dMatx
          $satFormStr << "#{$sumOfWeights+1} -#{pMatx[i][j][k]} ";
          for l in 0..nofCity-3
            $satFormStr << "#{dMatx[l][j-1][k-1]} ";
          end
          $satFormStr << "0\n";
          $nofClause += 1;
          # from dMatx to pMatx
          if i == nofSMan-1
            for l in 0..nofCity-3
              $satFormStr << "#{$sumOfWeights+1} -#{dMatx[l][j-1][k-1]} ";
              for m in 0..nofSMan-1
                $satFormStr << "#{pMatx[m][j][k]} ";
              end
              $satFormStr << "0\n";
              $nofClause += 1;
            end
          end
        end
      end
    end
  end
    
  # depth columns atMostOne constraints
  for i in 0..nofCity-2
    tmpArr.clear();
    for j in 0..nofCity-3
      for k in 0..nofCity-2
        if k != i
          tmpArr.push(dMatx[j][k][i]);
        end
      end
    end
    atMostOne(tmpArr);
  end
  
  # first depth interface
  for i in 0..nofSMan-1
    for j in 1..nofCity-1
      $satFormStr << "#{$sumOfWeights+1} -#{pMatx[i][0][j]} ";
      for k in 0..nofCity-2
        if k != j-1
          $satFormStr << "#{dMatx[0][j-1][k]} ";
        end
      end
      $satFormStr << "#{pMatx[i][j][0]} 0\n";
      $nofClause += 1;
    end
  end
  
=begin
  # Last depth (i.e., cross section) atMostOne constraints
  tmpArr.clear();
  for i in 0..nofCity-2
    for j in 0..nofCity-2
      if j != i
        tmpArr.push(dMatx[nofCity-3][i][j]);
      end
    end
  end
  atMostOne(tmpArr);
=end
  
  # next depth guide constraints
  for i in 0..nofCity-3
    for j in 0..nofCity-2
      for k in 0..nofCity-2
        if k != j
          $satFormStr << "#{$sumOfWeights+1} -#{dMatx[i][j][k]} ";
          if i < nofCity-3
            for l in 0..nofCity-2
              if l != k
                $satFormStr << "#{dMatx[i+1][k][l]} ";
              end
            end
          end
          for l in 0..nofSMan-1
            $satFormStr << "#{pMatx[l][k+1][0]} ";
          end
          $satFormStr << "0\n";
          $nofClause += 1;
        end
      end
    end
  end

=begin
  # rest depths block constraints (acyclic)
  for i in 0..nofCity-3
    for j in 0..nofCity-2
      for k in 0..nofCity-2
        if k != j
          for l in i..nofCity-3
            for m in 0..nofCity-2
              if m != j
                $satFormStr << "#{$sumOfWeights+1} -#{dMatx[i][j][k]} -#{dMatx[l][m][j]} 0\n";
                $nofClause += 1;
              end
            end
          end
        end
      end
    end
  end
=end
  
  # Eq.8
  for i in 0..nofSMan-1
    for j in 0..nofCity-1
      for k in 0..nofCity-1
        if k != j
          $satFormStr << "#{wMatx[j][k]} -#{pMatx[i][j][k]} 0 #{i+1}\n";
          $nofClause += 1;
        end
      end
    end
  end
  
  #puts $satFormStr;
  printMatx(wMatx);
  
  # write SAT file
  writeSAT(fileName[0, fileName.size-4] + "_m#{nofSMan}.wcnf");
  ## SAT end <-

  reset();
end

# ARGV[0]: "fileName", ARGV[1]: "m=nofSMan"
insGen(ARGV[0], ARGV[1]);

















