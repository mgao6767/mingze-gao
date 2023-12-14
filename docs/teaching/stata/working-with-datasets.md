---
date: 2023-07-31
draft: false
tags:
- Stata
disqus: true
---

# Stata - Working with datasets

!!! note inline end "Recap"

    We can use the command `sysuse` to use builtin datasets, and `use` to load other external datasets.

In the [introduction](../introduction#load-dataset), we briefly mentioned how to load Stata datasets to use. Now, let's take a more in-depth look at how we work with datasets in Stata.

## Datasets, here and there

Datasets are stored at different places, locally on our computer's hard disk or remotely on a server. For Stata to use them, we need to load them into Stata, or putting them into memory.

Because Stata commands (e.g., `summarize`, `describe`, `count`, etc.) operate on the **current** dataset in memory, working simultaneously on multiple datasets _was_ painful -- one needs to save current, load the other dataset, perform tasks and save/load again. But since ==Stata 16==, a feature called `frame` is introduced, where different datasets can be loaded into memory at the same time, but in different "frames". The chart below gives a simple illustration.

```mermaid
flowchart LR
  subgraph Stata
    direction TB
    Engine
    Engine -->|frame change| default & frame2 & frame3 & ...
    subgraph default
    end
    subgraph frame2
    end
    subgraph ...
    end
    subgraph frame3
    end
  end


  
  default -->|sysuse| auto.dta
  frame2 -->|use| /User/mgao/Desktop/anotherDataset.dta
  frame3 -->|use| http://www.stata-press.com/data/r13/nlswork.dta

  subgraph network
    http://www.stata-press.com/data/r13/nlswork.dta
  end
    subgraph local
    /User/mgao/Desktop/anotherDataset.dta
  end
    subgraph builtin
    auto.dta
  end
```

Although we still can only operate Stata commands on a single frame/dataset at a given time, we no longer need to save/load datasets as they all reside in memory frames.

!!! tip

    We as beginners can be agnostic about `frame`, especially when dealing with only one dataset throughout. Technically, we are loading data into the `default` frame (1), and work in the default frame. 
    { .annotate }
    
    1. `default` frame is just a frame named "default".

## But we start with loading and saving

### Stata's `dta`

The `dta` is Stata's proprietary binary data file format, and is the default file format used by Stata.

What I like very much about the `dta` data format include:

1. **Variable Types**: `dta` files can store different types of variables, including numeric variables (e.g., integers, floats) and string variables (text). It can represent missing values too.
1. **Metadata**: `dta` files can store metadata, such as variable labels (descriptive names for variables), value labels (labels for specific variable values), and variable formats (e.g., date formats).
1. **Cross-Platform Compatibility**: `dta` files created in one version of Stata can generally be read by other versions of Stata, ensuring cross-platform compatibility.

Also, `dta` files are typically compressed to reduce file size and optimize storage.

More importantly, Stata provides commands (`use`, `save`, etc.) to read data from `dta` files into memory and save data from memory to `dta` files. This makes it extremely easy to work with.

For example, you can easily load a Stata dataset online to your Stata via `use`:

```stata
use "http://www.stata-press.com/data/r13/nlswork.dta", clear
```

Note that `, clear` option tells Stata to clear the memory (1) in case there is already some other dataset in it.
{ .annotate }

1. Note that it does not clear the _entire_ memory - datasets in other frames are not cleared. Only the dataset, if any, in the current frame is cleared when the new dataset is loaded.

Alternatively, you can [download the `nlswork.dta` dataset](http://www.stata-press.com/data/r13/nlswork.dta) to your computer, and load it from your local computer:

=== ":fontawesome-brands-apple: Mac / :fontawesome-brands-linux: Linux"

    ```stata
    use "/Users/mgao/Downloads/nlswork.dta", clear
    ```

=== ":fontawesome-brands-windows: Windows"

    ```stata
    use "C:\Users\mgao\Downloads\nlswork.dta", clear
    ```

After some work on the dataset, say, keeping only observations where `year` is 88,

```stata
keep if year==88
```

we can save the modified dataset either to its original place, overwriting the original dataset, or to a different place, creating a new dataset:  

=== ":fontawesome-brands-apple: Mac / :fontawesome-brands-linux: Linux"

    ```stata
    save "/Users/mgao/Downloads/nlswork.dta", replace
    ```

=== ":fontawesome-brands-windows: Windows"

    ```stata
    save "C:\Users\mgao\Downloads\nlswork.dta", replace
    ```

### Mighty `csv`

We all love `csv` or "comma-separated-values" files. They are simple and readable without requiring any special software.(1) Many datasets are also published online in `csv` format.
{ .annotate }

1. You don't need Excel or Numbers to open `csv` files, in case you didn't know...

What if we want to save a `csv` version of the dataset? Easy, we use `export` command:

=== ":fontawesome-brands-apple: Mac / :fontawesome-brands-linux: Linux"

    ```stata
    export delimited using "/Users/mgao/Downloads/nlswork.csv", replace
    ```

=== ":fontawesome-brands-windows: Windows"

    ```stata
    export delimited using "C:\Users\mgao\Downloads\nlswork.csv", replace
    ```

Of course, we can import the `csv` file back to Stata using `import` command:

=== ":fontawesome-brands-apple: Mac / :fontawesome-brands-linux: Linux"

    ```stata
    import delimited using "/Users/mgao/Downloads/nlswork.csv", clear 
    ```

=== ":fontawesome-brands-windows: Windows"

    ```stata
    import delimited using "C:\Users\mgao\Downloads\nlswork.csv", clear
    ```

In some rare cases where the text file is not delimited/separated by comma, we can manually specify the delimiter. For example, some datasets use "tab-separated-values" or `tsv` format:

```stata
import delimited "path/to/datafile.tsv", delimiter(tab)
```

### Did someone say "Excel"?

Stata gets you covered. `import excel` is all you need.

For example, we next are to use an Excel spreadsheet named [:octicons-download-24: "BUSS7902 Chapter 4A Lecture (Data).xlsx"](https://github.com/mgao6767/BUSS7902/raw/main/spreadsheet/BUSS7902%20Chapter%204A%20Lecture%20(Data).xlsx).

Before everything, we can ask Stata to describe the file:

```stata
. import excel "~/Downloads/BUSS7902 Chapter 4A Lecture (Data).xlsx", describe

             Sheet | Range
  -----------------+-----------------
         Magic Box | A1:C101
          Assembly | A1:H76
          Distance | A1:L42
  Insurance+Survey | A1:H1501
```

As shown, the spreadsheet contains four sheets of different names, "Magic Box" and so on. Let's say we are interested in the data in the "Magic Box" sheet,(1) we can instruct Stata to load data from the sheet and optionally specify the data range in the sheet.(2)
{ .annotate }

1. The "Magic Box" sheet, as with other sheets, contains more than just data, but also some text. We want only data in the first column A.
2. We also use the `firstrow` option to tell Stata to treat the first row as variable name, not value of an observation.

```stata
. import excel "~/Downloads/BUSS7902 Chapter 4A Lecture (Data).xlsx", firstrow sheet("Magic Box") cellrange(A1:A101) clear
(1 var, 100 obs)
```

And that's it! Stata will take care of the variable type and etc., and is pretty good at it most of the time.

## So you want more `frame`s?

!!! tip

    This is for the tech-savvy. You don't need `frame` almost surely.

Okay. So you noticed that every time we import/use a new dataset, we set the `clear` option to clear the memory, discarding whatever dataset we currently work on to make room for new new dataset. This is troublesome. What if we don't want to give up the intermediate results while taking a peak at the different dataset?

We make a new `frame` and load the new dataset into the new frame.(1)
{ .annotate }

1. Remember that the frame we work on so far is named "default".

Let's have a look first at what frames are currently there:

```stata
. frame list
* default  100 x 1

Note: Frames marked with * contain unsaved data.
```

### Create a new frame

We create a new `frame` to which a new dataset can be loaded without clearing the existing dataset in the default frame. We can name it whichever we like, say, "assembly":

```stata
frame create "assembly"
```

Now check again the frames, we can see it is indeed there.

```stata
. frame list
  assembly  0 x 0
* default   100 x 1

Note: Frames marked with * contain unsaved data.
```

### Change to the new frame

Let's now switch to the newly created "assembly" frame, leaving the "Magic Box" data untouched in the default frame.

```stata
frame change assembly
```

!!! tip inline end

    Forgot which frame you are in?

    ```stata
    . frame
    (current frame is assembly)
    ```

You may notice that the **Variables** window is now blank, showing that there is no variable in this frame. Rest assured that the [`x` variable we imported earlier from "Magic Box" sheet](#__codelineno-12-1) stays in memory and in the default frame.

We can now load data into this empty frame using the same methods as discussed above.

For example, I can now load the data in the "Assembly" sheet into the frame.

```stata
. import excel "~/Downloads/BUSS7902 Chapter 4A Lecture (Data).xlsx", firstrow sheet("Assembly") cellrange(A1:A76) clear case(lower)
(1 var, 75 obs)
```

If we check the frames, we can see that now both datasets exist in memory, albeit in two frames.

```stata
. frame list
* assembly  75 x 1
* default   100 x 1

Note: Frames marked with * contain unsaved data.
```

To go back to the original frame (named "default"), use `frame change default`.
