From: "Patil, Harish" <harish.patil@intel.com>
Date: Fri, 20 Dec 2002 01:46:54 +0000
Subject: RE: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen val
Message-Id: <marc-linux-ia64-105590709805626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Thursday, December 19, 2002 3:19 PM
> To: Patil, Harish
> Cc: 'davidm@hpl.hp.com'; 'linux-ia64@linuxia64.org'
> Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen
> values
> 
> 
> >>>>> On Tue, 17 Dec 2002 08:33:38 -0800, "Patil, Harish" 
> <harish.patil@intel.com> said:
> 
>   Harish> I have a RHAS kernel compiled with *gcc3.2*. Using a script
>   Harish> based on readelf/objdmp I found out that there are 7
>   Harish> instances in this kernel where 'rlen' may be wrong. The
>   Harish> invariant the script is looking for is this: Sum(rlen for
>   Harish> various regions) = Number of slots in the code range.
> 
>   Harish> The script found following violations of the invariant:

<stuff deleted>

> 
>   Harish> code_range= 0xe000000004b18000-0xe000000004b182b0
>   Harish>         lo =  4B18000  hi = 4B182B0
>   Harish>         sum_rlen =  130 no_slots = 129
>   Harish>             *******ERROR ***********
>   Harish>             sum_rlen: 130  != no_slots:129
> 
> Do you know what code this is?  The addresses are not terribly useful
> because they'll vary from one kernel to another.

Sorry, the procedure name somehow got lost.. I disassembled the image and
the relevant procedure is:  <ia64_sigtramp>

> Is your script fully automatic?  If so, perhaps we could add it to the
> kernel sources and run it as part of "make check".  I'd love to have
> better unwind-info checking tools.  Actually, it's even more important
> to use such tools to verify the correctness of the user-level unwind
> info.

Yes, the script is fully automatic and is included below (requires a
'readelf' that 
understands "-u" option).

-Harish
<----------- BEGIN unwcheck.sh
#!/bin/sh 
#   Usage: unwcheck.sh <executable_file_name>
#   Pre-requisite: readelf [from Gnu binutils package]
#   Purpose: Check the following invariant
#       For each code range in the input binary:
#          Sum[ lengths of unwind regions] = Number of slots in code range.
#   Author : Harish Patil
#   First version: January 2002
#   Modified : 2/13/2002
#   Modified : 3/15/2002: duplicate detection
readelf -u $1 | gawk '\
 function todec(hexstr){
    dec = 0;
    l = length(hexstr);
    for (i = 1; i <= l; i++)
    {
        c = substr(hexstr, i, 1);
        if (c = "A")
            dec = dec*16 + 10;
        else if (c = "B")
            dec = dec*16 + 11;
        else if (c = "C")
            dec = dec*16 + 12;
        else if (c = "D")
            dec = dec*16 + 13;
        else if (c = "E")
            dec = dec*16 + 14;
        else if (c = "F")
            dec = dec*16 + 15;
        else 
            dec = dec*16 + c;
    }
    return dec;
 }
 BEGIN { first = 1; sum_rlen = 0; no_slots = 0; errors=0; no_code_ranges=0;
}
 {
   if (NF=5 && $3="info")
   {
      no_code_ranges += 1;
      if (first = 0)
      {
         if (sum_rlen != no_slots) 
         {
            print full_code_range;
            print "       ", "lo = ", lo, " hi =", hi;
            print "       ", "sum_rlen = ", sum_rlen, "no_slots = "
no_slots;
            print "       ","   ", "*******ERROR ***********";
            print "       ","   ", "sum_rlen:", sum_rlen, " != no_slots:"
no_slots;
            errors += 1;
         }
         sum_rlen = 0;
      }
      full_code_range =  $0;
      code_range =  $2;
      gsub("),", "", code_range);
      gsub("^.", "", code_range);
      split(code_range, addr, "-");
      lo = toupper(addr[1]);

      code_range_lo[no_code_ranges] = addr[1];
      occurs[addr[1]] += 1;
      full_range[addr[1]] = $0;

      gsub("0X.[0]*", "", lo);
      hi = toupper(addr[2]);
      gsub("0X.[0]*", "", hi);
      no_slots = (todec(hi) - todec(lo))/ 16*3
      first = 0;
   }
   if (index($0,"rlen") > 0 )
   {
    rlen_str =  substr($0, index($0,"rlen"));
    rlen = rlen_str;
    gsub("rlen=", "", rlen);
    gsub(")", "", rlen);
    sum_rlen = sum_rlen +  rlen;
   }
  }
  END {
      if (first = 0)
      {
         if (sum_rlen != no_slots) 
         {
            print "code_range=", code_range;
            print "       ", "lo = ", lo, " hi =", hi;
            print "       ", "sum_rlen = ", sum_rlen, "no_slots = "
no_slots;
            print "       ","   ", "*******ERROR ***********";
            print "       ","   ", "sum_rlen:", sum_rlen, " != no_slots:"
no_slots;
            errors += 1;
         }
      }
    no_duplicates = 0;
    for (i=1; i<=no_code_ranges; i++)
    {
        cr = code_range_lo[i];
        if (reported_cr[cr]=1) continue;
        if ( occurs[cr] > 1)
        {
            reported_cr[cr] = 1;
            print "Code range low ", code_range_lo[i], ":", full_range[cr],
" occurs: ", occurs[cr], " times.";
            print " ";
            no_duplicates++;
        }
    }
    print "==================="
    print "Total errors:", errors, "/", no_code_ranges, " duplicates:",
no_duplicates;
    print "==================="
  }
  '
---> END unwcheck.sh [note the "'" (single quote) on the last line ]

