From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Mon, 15 Jan 2007 05:20:22 +0000
Subject: Re: efi.get_variable causing Oops
Message-Id: <5e0a1fd80701142108o10b340a9kac0b7cd60e2da19f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80701080453i203f866dp305dd8de664525dd@mail.gmail.com>
In-Reply-To: <5e0a1fd80701080453i203f866dp305dd8de664525dd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

    I have not managed to make any progress on this front. :-( The IP
is at 0xe0000743fc185650. Here is the complete trace.

-------------------------------------------

Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 8804682956800 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2010 ifs : 8000000000000714 ip  :
[<e0000743fc185650>]    Not tainted
ip is at 0xe0000743fc185650
unat: 0000000000000000 pfs : 0000000000000714 rsc : 0000000000000003
rnat: 80000ffc10119ed0 bsps: 0000000000000000 pr  : 80000000ff7a068b
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e0000743fc185640 b6  : e0000743fc419b70 b7  : e0000743fc4b0c00
f6  : 000000000000000000000 f7  : 0ffdea000000000000000
f8  : 10002a000000000000000 f9  : 100038000000000000000
f10 : 0fffe9ffffffff6000000 f11 : 1003e0000000000000000
r1  : e0000743fc163c00 r2  : 0000000000000000 r3  : 0000000000020000
r8  : 000000000000000c r9  : 0000001008020000 r10 : e0000743fc6c9190
r11 : 0000000000000000 r12 : a000000100a1b6b0 r13 : a000000100a14000
r14 : 0000000000000007 r15 : 0000000000000006 r16 : e0000743fc6c83a0
r17 : a000000100a1b600 r18 : a000000100a1b608 r19 : a000000100a1b558
r20 : 0000000000000011 r21 : 0000000000000000 r22 : 00000010084a2010
r23 : c0000ffc201095be r24 : c0000ffc201095bf r25 : 0000000000000000
r26 : a000000100a1b6d6 r27 : a000000100a1b6d7 r28 : a000000100a1b720
r29 : 0000000000000000 r30 : 80000000ff7a064b r31 : 000000000000050f
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 11012296146944 [2]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 0000121008022018 ifs : 8000000000000308 ip  :
[<a000000100115fc1>]    Not tainted
ip is at kmem_cache_alloc+0x41/0x100
unat: 0000000000000000 pfs : 0000000000000793 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000ff7a69a7
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100039c00 b6  : a00000010003a9e0 b7  : a00000010000bd50
f6  : 1003e137c75840bac330a f7  : 1003e9e3779b97f4a7c16
f8  : 1003e0a000000100010af f9  : 1003e000000000000007f
f10 : 1003e0000000000000379 f11 : 1003e6db6db6db6db6db7
r1  : a000000100dc8ee0 r2  : 0000000000000000 r3  : 0000000000000000
r8  : 0000000000000000 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : a000000100a1ab20 r13 : a000000100a14000
r14 : a000000100a14b64 r15 : 000000000000000f r16 : a000000100a1abb0
r17 : 0000000000000000 r18 : a000000100a86c08 r19 : a000000100a1abac
r20 : a000000100a1aba8 r21 : 000000007fffffff r22 : 0000000000000000
r23 : a000000100010af0 r24 : a000000100010aa0 r25 : a000000100000000
r26 : a000000100a95070 r27 : a000000100bca168 r28 : a000000100a8df70
r29 : a000000100a8df60 r30 : 00000000000000c4 r31 : 0000000000010b40

-------------------------------------------

    As I have mentioned before, using the "EFI_GLOBAL_VARIABLE_GUID"
does not Oops. So can there be something wrong with my GUID? If there
is, can it Oops? I have no clue as to how to proceed. Any help will be
appreciated.

Thanks & Regards,
Karthik

On 1/8/07, Karthik Gopalakrishnan <karthik.g.krishnan@gmail.com> wrote:
> OK. Some progress. If I use "EFI_GLOBAL_VARIABLE_GUID" instead of my
> "CONFIG_GUID", the get_variable call returns a failure but does not
> Oops. So, can an invalid GUID cause an Oops?
>
> On 1/8/07, Karthik Gopalakrishnan <karthik.g.krishnan@gmail.com> wrote:
> > Hi Folks.
> >
> >     I am calling the following function as the last function in
> > setup_arch() [well after efi_init()] on a 2.6.19 kernel.
> >
> > void __init func_foo (void)
> > {
> >     unsigned char       data[1024];
> >     unsigned long       size = sizeof(data);
> >     char                *Ascii_String;
> >     efi_char16_t        *Unicode_String;
> >     char                mode_name[] = "variable_name";
> >     efi_char16_t        mode_name_utf[32];
> >     efi_guid_t          guid = CONFIG_GUID;
> >     efi_status_t        status;
> >     int                 i;
> >
> >     Unicode_String = mode_name_utf;
> >     Ascii_String   = mode_name;
> >     while (*Ascii_String)
> >         *Unicode_String++ = *Ascii_String++ & 0x7F;
> >     *Unicode_String = 0;
> >
> >     status = efi.get_variable(mode_name_utf, &guid, NULL, &size, data);
> >     ...
> >     ...
> >     ...
> > }
> >
> >     The get_variable call is causing an Oops.
> >
> > Unable to handle kernel NULL pointer dereference (address 0000000000000000)
> > swapper[0]: Oops 11012296146944 [2]
> >
> >     Can someone tell me why it is page-faulting? Any suggestions as to
> > where to start looking?
> >
> > Thanks & Regards,
> > Karthik
> >
>
