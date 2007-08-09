From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 09 Aug 2007 17:53:15 +0000
Subject: Re: need NOTES in vmlinux.lds.S
Message-Id: <ed5aea430708091053h11b8fbd6pd88d7bed31823535@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_132587_1175847.1186681995866"
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
In-Reply-To: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
To: linux-ia64@vger.kernel.org

------=_Part_132587_1175847.1186681995866
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 8/9/07, Roland McGrath <roland@redhat.com> wrote:
> That placement is probably fine (the standard size is 36 bytes, so don't
> fret too much about how optimal its location is).  Since ia64 has an
> explicit PHDRS, it would be ideal to add there a "note PT_NOTE" and then use:
>
>         NOTES :code :note
>         code_continues : { } :code
>
> Instead of the second line you can append :code to the next brace group.
> (Without one or the other, the following sections will also be included in
> the size of the PT_NOTE segment.)
>
> Adding the PT_NOTE phdr is not essential, but it keeps vmlinux holding to
> that standard ELF convention, and it's what the other machines do.

Sure, that sounds reasonable.  Updated patch attached.

I tried this patch with Linus' 2.6.23-rc2 tree and the resulting
kernel boots fine, though there are some scary-looking error messages:

WARNING: at /data/sc/linux-2.6/kernel/irq/resend.c:70 check_irq_resend()

Call Trace:
 [<a0000001000132e0>] show_stack+0x80/0xa0
                                sp=e00000407ff97bc0 bsp=e00000407ff90f58
 [<a000000100013330>] dump_stack+0x30/0x60
                                sp=e00000407ff97d90 bsp=e00000407ff90f40
 [<a0000001000db860>] check_irq_resend+0x1e0/0x200
                                sp=e00000407ff97d90 bsp=e00000407ff90ef8
 [<a0000001000dadd0>] enable_irq+0x210/0x240
                                sp=e00000407ff97d90 bsp=e00000407ff90ec8
 [<a0000001004f9aa0>] probe_hwif+0x440/0x1800
                                sp=e00000407ff97d90 bsp=e00000407ff90db0
 [<a0000001004fc7d0>] probe_hwif_init_with_fixup+0x30/0x180
                                sp=e00000407ff97d90 bsp=e00000407ff90d80
 [<a0000001005037c0>] ide_setup_pci_device+0x160/0x1c0
                                sp=e00000407ff97d90 bsp=e00000407ff90d40
 [<a0000001004e2670>] init_setup_cmd64x+0x30/0x60
                                sp=e00000407ff97da0 bsp=e00000407ff90d18
 [<a0000001004e25c0>] cmd64x_init_one+0x140/0x160
                                sp=e00000407ff97da0 bsp=e00000407ff90cf0
 [<a000000100933a10>] ide_scan_pcidev+0xf0/0x180
                                sp=e00000407ff97e00 bsp=e00000407ff90cb8
 [<a000000100933b20>] ide_scan_pcibus+0x80/0x2e0
                                sp=e00000407ff97e00 bsp=e00000407ff90c80
 [<a0000001009338c0>] ide_init+0xc0/0x120
                                sp=e00000407ff97e00 bsp=e00000407ff90c60
 [<a0000001009003c0>] kernel_init+0x1a0/0x6a0
                                sp=e00000407ff97e00 bsp=e00000407ff90c00
 [<a0000001000113b0>] kernel_thread_helper+0xd0/0x100
                                sp=e00000407ff97e30 bsp=e00000407ff90bd0
 [<a000000100008dc0>] start_kernel_thread+0x20/0x40
                                sp=e00000407ff97e30 bsp=e00000407ff90bd0

and a bunch of these:

 target0:0:6: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 62)
sd 0:0:6:0: [sdb] Device not ready: <6>: Sense Key : Not Ready [current]
: Add. Sense: Logical unit not ready, initializing command required

However, the kernel still works fine, as near as I can tell and I
don't think these errors are due to my patch. ;-)

Tony, can you apply this to your tree?

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_132587_1175847.1186681995866
Content-Type: text/plain; name="note.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="note.diff"
X-Attachment-Id: f_f55jszkl

W0lBNjRdIEFkZCBOT1RFUyB0byBsaW5rZXIgc2NyaXB0IHN1Y2ggdGhhdCB0aGUga2VybmVsIGNh
biBiZSBidWlsdCB3aXRoCiAgICAgICByZWNlbnQgdmVyc2lvbnMgb2YgYmludXRpbHMuICBXaXRo
b3V0IHRoaXMgcGF0Y2gsIGZpbmFsIGxpbmsgZmFpbHMKICAgICAgIHdpdGggdGhpcyBlcnJvcjoK
CiAgICAgICAgbGQ6IC50bXBfdm1saW51eDE6IHNlY3Rpb24gYC50ZXh0JyBjYW4ndCBiZSBhbGxv
Y2F0ZWQgaW4gc2VnbWVudCAwCiAgICAgICAgbGQ6IGZpbmFsIGxpbmsgZmFpbGVkOiBCYWQgdmFs
dWUKCiAgICAgICBUaGlzIGVycm9yIGlzIGR1ZSB0byB0aGUgZmFjdCB0aGF0IHRoZSAtLWJ1aWxk
LWlkIG9wdGlvbiBpcyB1c2VkCiAgICAgICB3aXRoIG5ld2VyIGxpbmtlcnMgdG8gaW5jbHVkZSBh
IC5ub3RlcyBzZWN0aW9uIG9uIHRoZSBrZXJuZWwsIGJ1dAogICAgICAgd2l0aG91dCB0aGUgTk9U
RVMgbWFjcm8sIHRoYXQgc2VjdGlvbiB3b24ndCBiZSBpbmNsdWRlZCBpbiB0aGUga2VybmVsCiAg
ICAgICB3aGljaCB0aGVuIGxlYWRzIHRvIHRoZSBhYm92ZSBlcnJvciBtZXNzYWdlLgoKU2lnbmVk
LW9mZi1ieTogRGF2aWQgTW9zYmVyZ2VyLVRhbmcgPGRtb3NiZXJnZXJAZ21haWwuY29tPgoKZGlm
ZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5sZHMuUyBiL2FyY2gvaWE2NC9rZXJu
ZWwvdm1saW51eC5sZHMuUwppbmRleCA4M2U4MDY3Li40NDZmMTJkIDEwMDY0NAotLS0gYS9hcmNo
L2lhNjQva2VybmVsL3ZtbGludXgubGRzLlMKKysrIGIvYXJjaC9pYTY0L2tlcm5lbC92bWxpbnV4
Lmxkcy5TCkBAIC0yMCw2ICsyMCw3IEBAIFBIRFJTIHsKICAgY29kZSAgIFBUX0xPQUQ7CiAgIHBl
cmNwdSBQVF9MT0FEOwogICBkYXRhICAgUFRfTE9BRDsKKyAgbm90ZSAgIFBUX05PVEU7CiB9CiBT
RUNUSU9OUwogewpAQCAtNjIsNiArNjMsOSBAQCBTRUNUSU9OUwogCiAgIC8qIFJlYWQtb25seSBk
YXRhICovCiAKKyAgTk9URVMgOmNvZGUgOm5vdGUJCS8qIHB1dCAubm90ZXMgaW4gdGV4dCBhbmQg
bWFyayBpbiBQVF9OT1RFICAqLworICBjb2RlX2NvbnRpbnVlcyA6IHt9IDpjb2RlCS8qIHN3aXRj
aCBiYWNrIHRvIHJlZ3VsYXIgcHJvZ3JhbS4uLiAgKi8KKwogICAvKiBFeGNlcHRpb24gdGFibGUg
Ki8KICAgLiA9IEFMSUdOKDE2KTsKICAgX19leF90YWJsZSA6IEFUKEFERFIoX19leF90YWJsZSkg
LSBMT0FEX09GRlNFVCkKQEAgLTI3NiwxMCArMjgwLDYgQEAgU0VDVElPTlMKICAgLmRlYnVnX3R5
cGVuYW1lcyAwIDogeyAqKC5kZWJ1Z190eXBlbmFtZXMpIH0KICAgLmRlYnVnX3Zhcm5hbWVzICAw
IDogeyAqKC5kZWJ1Z192YXJuYW1lcykgfQogICAvKiBUaGVzZSBtdXN0IGFwcGVhciByZWdhcmRs
ZXNzIG9mICAuICAqLwotICAvKiBEaXNjYXJkIHRoZW0gZm9yIG5vdyBzaW5jZSBJbnRlbCBTb2Z0
U0RWIGNhbm5vdCBoYW5kbGUgdGhlbS4KLSAgLmNvbW1lbnQgMCA6IHsgKiguY29tbWVudCkgfQot
ICAubm90ZSAwIDogeyAqKC5ub3RlKSB9Ci0gICovCiAgIC9ESVNDQVJELyA6IHsgKiguY29tbWVu
dCkgfQogICAvRElTQ0FSRC8gOiB7ICooLm5vdGUpIH0KIH0K
------=_Part_132587_1175847.1186681995866--
