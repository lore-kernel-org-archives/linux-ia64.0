From: Vaibhav Sharma <vaibhav.sh@gmail.com>
Date: Tue, 01 Mar 2005 13:44:44 +0000
Subject: Re: IA64 memory
Message-Id: <851caabb0503010532d746452@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi all, 

Thank you again for the details.

I have another query. I had downloaded a pdf concerning the zx1 memory
and I/O ("zx1 mio External reference specification"). In the system
address map, it shows that memory space is consisting of m0(1 GB),
m1(3GB) and m2 (252 GB), which means  m0+m1+m2= 1+ 3+252%6 GB*. Is
it that zx1 chip is capable of addressing RAM of 256 GB size only..if
my RAM is more than 256 GB, do I have to change the chip..?

(* not considering other areas like GMMIO, LMMIO etc)..

I have zx6000 hp machine. 

Plz do reply...

TIA, 
vaibhav



On Thu, 24 Feb 2005 10:40:58 -0800, Bukie Mabayoje <bukiemab@gte.net> wrote:
> Below is a sample memory map from EFI. You will see gaps between the memory types.
> The GRANULE is a chunk of available memory. e.g  the second line is a GRANULE  0x1000-0x6FFF
> 
> For trim_bottom refer to func trim_bottom():efi.c
> For trip_top refer to func trim_top():efi.c
> 
> Type       Start            End               # Pages          Attributes
> BS_data    0000000000000000-0000000000000FFF  0000000000000001 0000000000000009
> available  0000000000001000-0000000000006FFF  0000000000000006 0000000000000009
> BS_data    0000000000007000-0000000000008FFF  0000000000000002 0000000000000009
> available  0000000000009000-0000000000081FFF  0000000000000079 0000000000000009
> RT_data    0000000000082000-0000000000083FFF  0000000000000002 8000000000000009
> available  0000000000084000-0000000000084FFF  0000000000000001 0000000000000009
> BS_data    0000000000085000-000000000009FFFF  000000000000001B 0000000000000009
> RT_code    00000000000C0000-00000000000FFFFF  0000000000000040 8000000000000009
> available  0000000000100000-000000000FFBFFFF  000000000000FEC0 000000000000000B
> BS_data    000000000FFC0000-000000000FFFFFFF  0000000000000040 000000000000000B
> available  0000000010000000-000000007C92DFFF  000000000006C92E 000000000000000B
> LoaderData 000000007C92E000-000000007C937FFF  000000000000000A 000000000000000B
> LoaderCode 000000007C938000-000000007C97DFFF  0000000000000046 000000000000000B
> available  000000007C97E000-000000007CE29FFF  00000000000004AC 000000000000000B
> BS_data    000000007CE2A000-000000007D000FFF  00000000000001D7 000000000000000B
> available  000000007D001000-000000007D01DFFF  000000000000001D 000000000000000B
> BS_data    000000007D01E000-000000007D09BFFF  000000000000007E 000000000000000B
> available  000000007D09C000-000000007D09CFFF  0000000000000001 000000000000000B
> BS_data    000000007D09D000-000000007D37DFFF  00000000000002E1 000000000000000B
> available  000000007D37E000-000000007D6FFFFF  0000000000000382 000000000000000B
> BS_code    000000007D700000-000000007D77DFFF  000000000000007E 000000000000000B
> available  000000007D77E000-000000007D8B5FFF  0000000000000138 000000000000000B
> RT_data    000000007D8B6000-000000007D8FFFFF  000000000000004A 8000000000000009
> BS_code    000000007D900000-000000007F97FFFF  0000000000002080 000000000000000B
> available  000000007F980000-000000007F9FFFFF  0000000000000080 000000000000000B
> RT_code    000000007FA00000-000000007FDFFFFF  0000000000000400 8000000000000009
> PAL_code   000000007FE00000-000000007FE3FFFF  0000000000000040 8000000000000009
> RT_code    000000007FE40000-000000007FE97FFF  0000000000000058 8000000000000009
> available  000000007FE98000-000000007FED9FFF  0000000000000042 000000000000000B
> RT_code    000000007FEDA000-000000007FF45FFF  000000000000006C 8000000000000009
> RT_data    000000007FF46000-000000007FFFFFFF  00000000000000BA 8000000000000009
> MemMapIO   00000000FE000000-00000000FEFFFFFF  0000000000001000 0000000000000001
> RT_data    00000000FF000000-00000000FFFFFFFF  0000000000001000 8000000000000001
> MemMapIO   00000FFFF8000000-00000FFFFBFFFFFF  0000000000004000 8000000000000001
> MemPortIO  00000FFFFC000000-00000FFFFFFFFFFF  0000000000004000 8000000000000001
> 
> Vaibhav Sharma wrote:
> 
> > hi,
> > Thanks for the details regarding the elilo and the memory map..
> >
> > Actually my task involves investigating the IA64 memory code and I had
> > some more queries regarding the "efi_memmap_walk" function in efi.c.
> > It would be great if I could get some help regarding this.
> >
> > Here is the flow of the fuction(i may be wrong in my interpretation):
> >
> > 1. scan all the efi memory descriptors in a "for" loop.
> > 2. exclude the non-WB memory.
> > 3. find the granule address (the comments in the file say that
> > [granule address - non-WB memory address] gives the contigous WB
> > memory). Then calculate the non-WB address.
> > 4. in function "trim_bottom", it reduces the number of pages for the
> > decriptor according to the granule.
> > 5. recalculate the non-wb address (shift it forward??).
> > 6. calls trim_top according to the " last granule address".
> > 7. calculate "start" and "end" addresses for the zone, check   for merging.
> > 8. after moving across all the descriptors, calls "callback"
> >
> > Actually I am not able to understand what is a GRANULE in IA64 and how
> > is it calculated, which uses the IA64_GRANULE_SIZE define.Is it
> > because of the  un-implemented bits in ia64..?. Also, why is that the
> > granule size ("last granule size") is recalculated (trim_bottom
> > earlier and trim_top now).
> >
> > TIA..
> > ---
> > vaibhav
> >
>
