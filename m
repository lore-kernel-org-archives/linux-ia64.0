From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 09 May 2011 22:07:41 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0016e6d58af1b884e304a2df1234"
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz>
 <alpine.LSU.2.00.1105081303540.16151@sister.anvils> <alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz>
 <BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
In-Reply-To: <BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Michel Lespinasse <walken@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org

--0016e6d58af1b884e304a2df1234
Content-Type: text/plain; charset=ISO-8859-1

On Mon, May 9, 2011 at 8:57 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Hmm. One thing that strikes me is this problem also implies that the
> /proc/self/maps file is wrong for the GROWSUP case, isn't it?
>
> So I think we should not just apply your lock fix, but then *also*
> apply something like this:

Actually, I think we might be better off with something like this.

It makes a few more changes:

 - move the stack guard page checking in __get_user_pages() into the
rare case (ie we didn't find a page), since that's the only case we
care about (the thing about the guard page is that don't want to call
"handle_mm_fault()"). As a result, it's off any path where we can
possibly care about performance, so we might as well have a nice
helper function for both the grow-up and grow-down cases, instead of
trying to be clever and only look at the grow-down case for the first
page in the vma like you did in your patch.

   End result: simpler, more straightforward code.

 - Move the growsup/down helper functions to <linux/mm.h>, since the
/proc code really wants to use them too. That means that the
"vma_stack_continue()" function (which now got split up into two
cases, for the up/down cases) is now entirely just an internal helper
function - nobody else uses it, and the real interface are the
"stack_guard_page_xyz()"  functions. Renamed to be simpler.

 - changed that naming of those stack_guard_page functions to use
_start and _end instead of growsup/growsdown, since it actually takes
the start or the end of the page as the argument (to match the
semantics of the afore-mentioned helpers)

 - and finally, make /proc/<pid>/maps use these helpers for both the
up/down case, so now /proc/self/maps should work well for the growsup
case too.

Hmm?

The only oddish case is IA64 that actually has a stack that grows
*both* up and down. That means that I could make up a stack mapping
that has a single virtual page in it, that is both the start *and* the
end page. Now /proc/self/maps would actually show such a mapping with
"negative" size. That's interesting.

It would be easy enough to have a "if (end < start) end = start" there
for that case, but maybe it's actually interesting information.

Regardless, I'd like to hear whether this patch really does work on
PA-RISC and especially IA64. I think those are the only cases that
have a GROWSUP stack. And the IA64 case that supports both is the most
interesting, everybody else does just one or the other.

                    Linus

--0016e6d58af1b884e304a2df1234
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnhyom1j0

IGZzL3Byb2MvdGFza19tbXUuYyB8ICAgMTIgKysrKysrKy0tLS0tCiBpbmNsdWRlL2xpbnV4L21t
LmggfCAgIDI0ICsrKysrKysrKysrKysrKysrKysrKysrLQogbW0vbWVtb3J5LmMgICAgICAgIHwg
ICAxNiArKysrKysrLS0tLS0tLS0tCiAzIGZpbGVzIGNoYW5nZWQsIDM3IGluc2VydGlvbnMoKyks
IDE1IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL3Byb2MvdGFza19tbXUuYyBiL2ZzL3By
b2MvdGFza19tbXUuYwppbmRleCAyZTdhZGRmZDk4MDMuLjMxOGQ4NjU0OTg5YiAxMDA2NDQKLS0t
IGEvZnMvcHJvYy90YXNrX21tdS5jCisrKyBiL2ZzL3Byb2MvdGFza19tbXUuYwpAQCAtMjE0LDcg
KzIxNCw3IEBAIHN0YXRpYyB2b2lkIHNob3dfbWFwX3ZtYShzdHJ1Y3Qgc2VxX2ZpbGUgKm0sIHN0
cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hKQogCWludCBmbGFncyA9IHZtYS0+dm1fZmxhZ3M7CiAJ
dW5zaWduZWQgbG9uZyBpbm8gPSAwOwogCXVuc2lnbmVkIGxvbmcgbG9uZyBwZ29mZiA9IDA7Ci0J
dW5zaWduZWQgbG9uZyBzdGFydDsKKwl1bnNpZ25lZCBsb25nIHN0YXJ0LCBlbmQ7CiAJZGV2X3Qg
ZGV2ID0gMDsKIAlpbnQgbGVuOwogCkBAIC0yMjcsMTMgKzIyNywxNSBAQCBzdGF0aWMgdm9pZCBz
aG93X21hcF92bWEoc3RydWN0IHNlcV9maWxlICptLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSkKIAogCS8qIFdlIGRvbid0IHNob3cgdGhlIHN0YWNrIGd1YXJkIHBhZ2UgaW4gL3Byb2MvbWFw
cyAqLwogCXN0YXJ0ID0gdm1hLT52bV9zdGFydDsKLQlpZiAodm1hLT52bV9mbGFncyAmIFZNX0dS
T1dTRE9XTikKLQkJaWYgKCF2bWFfc3RhY2tfY29udGludWUodm1hLT52bV9wcmV2LCB2bWEtPnZt
X3N0YXJ0KSkKLQkJCXN0YXJ0ICs9IFBBR0VfU0laRTsKKwlpZiAoc3RhY2tfZ3VhcmRfcGFnZV9z
dGFydCh2bWEsIHN0YXJ0KSkKKwkJc3RhcnQgKz0gUEFHRV9TSVpFOworCWVuZCA9IHZtYS0+dm1f
ZW5kOworCWlmIChzdGFja19ndWFyZF9wYWdlX2VuZCh2bWEsIGVuZCkpCisJCWVuZCAtPSBQQUdF
X1NJWkU7CiAKIAlzZXFfcHJpbnRmKG0sICIlMDhseC0lMDhseCAlYyVjJWMlYyAlMDhsbHggJTAy
eDolMDJ4ICVsdSAlbiIsCiAJCQlzdGFydCwKLQkJCXZtYS0+dm1fZW5kLAorCQkJZW5kLAogCQkJ
ZmxhZ3MgJiBWTV9SRUFEID8gJ3InIDogJy0nLAogCQkJZmxhZ3MgJiBWTV9XUklURSA/ICd3JyA6
ICctJywKIAkJCWZsYWdzICYgVk1fRVhFQyA/ICd4JyA6ICctJywKZGlmZiAtLWdpdCBhL2luY2x1
ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaAppbmRleCAyMzQ4ZGIyNmJjM2QuLjY1
MDdkZGUzOGIxNiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9tbS5oCisrKyBiL2luY2x1ZGUv
bGludXgvbW0uaApAQCAtMTAxMSwxMSArMTAxMSwzMyBAQCBpbnQgc2V0X3BhZ2VfZGlydHlfbG9j
ayhzdHJ1Y3QgcGFnZSAqcGFnZSk7CiBpbnQgY2xlYXJfcGFnZV9kaXJ0eV9mb3JfaW8oc3RydWN0
IHBhZ2UgKnBhZ2UpOwogCiAvKiBJcyB0aGUgdm1hIGEgY29udGludWF0aW9uIG9mIHRoZSBzdGFj
ayB2bWEgYWJvdmUgaXQ/ICovCi1zdGF0aWMgaW5saW5lIGludCB2bWFfc3RhY2tfY29udGludWUo
c3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVkIGxvbmcgYWRkcikKK3N0YXRpYyBp
bmxpbmUgaW50IHZtYV9ncm93c2Rvd24oc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHVuc2ln
bmVkIGxvbmcgYWRkcikKIHsKIAlyZXR1cm4gdm1hICYmICh2bWEtPnZtX2VuZCA9PSBhZGRyKSAm
JiAodm1hLT52bV9mbGFncyAmIFZNX0dST1dTRE9XTik7CiB9CiAKK3N0YXRpYyBpbmxpbmUgaW50
IHN0YWNrX2d1YXJkX3BhZ2Vfc3RhcnQoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCisJCQkJ
CSAgICAgdW5zaWduZWQgbG9uZyBhZGRyKQoreworCXJldHVybiAodm1hLT52bV9mbGFncyAmIFZN
X0dST1dTRE9XTikgJiYKKwkJKHZtYS0+dm1fc3RhcnQgPT0gYWRkcikgJiYKKwkJIXZtYV9ncm93
c2Rvd24odm1hLT52bV9wcmV2LCBhZGRyKTsKK30KKworLyogSXMgdGhlIHZtYSBhIGNvbnRpbnVh
dGlvbiBvZiB0aGUgc3RhY2sgdm1hIGJlbG93IGl0PyAqLworc3RhdGljIGlubGluZSBpbnQgdm1h
X2dyb3dzdXAoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVkIGxvbmcgYWRkcikK
K3sKKwlyZXR1cm4gdm1hICYmICh2bWEtPnZtX3N0YXJ0ID09IGFkZHIpICYmICh2bWEtPnZtX2Zs
YWdzICYgVk1fR1JPV1NVUCk7Cit9CisKK3N0YXRpYyBpbmxpbmUgaW50IHN0YWNrX2d1YXJkX3Bh
Z2VfZW5kKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLAorCQkJCQkgICB1bnNpZ25lZCBsb25n
IGFkZHIpCit7CisJcmV0dXJuICh2bWEtPnZtX2ZsYWdzICYgVk1fR1JPV1NVUCkgJiYKKwkJKHZt
YS0+dm1fZW5kID09IGFkZHIpICYmCisJCSF2bWFfZ3Jvd3N1cCh2bWEtPnZtX25leHQsIGFkZHIp
OworfQorCiBleHRlcm4gdW5zaWduZWQgbG9uZyBtb3ZlX3BhZ2VfdGFibGVzKHN0cnVjdCB2bV9h
cmVhX3N0cnVjdCAqdm1hLAogCQl1bnNpZ25lZCBsb25nIG9sZF9hZGRyLCBzdHJ1Y3Qgdm1fYXJl
YV9zdHJ1Y3QgKm5ld192bWEsCiAJCXVuc2lnbmVkIGxvbmcgbmV3X2FkZHIsIHVuc2lnbmVkIGxv
bmcgbGVuKTsKZGlmZiAtLWdpdCBhL21tL21lbW9yeS5jIGIvbW0vbWVtb3J5LmMKaW5kZXggMjdm
NDI1Mzc4MTEyLi42MWU2NmYwMjY1NjMgMTAwNjQ0Ci0tLSBhL21tL21lbW9yeS5jCisrKyBiL21t
L21lbW9yeS5jCkBAIC0xNDEyLDkgKzE0MTIsOCBAQCBub19wYWdlX3RhYmxlOgogCiBzdGF0aWMg
aW5saW5lIGludCBzdGFja19ndWFyZF9wYWdlKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1
bnNpZ25lZCBsb25nIGFkZHIpCiB7Ci0JcmV0dXJuICh2bWEtPnZtX2ZsYWdzICYgVk1fR1JPV1NE
T1dOKSAmJgotCQkodm1hLT52bV9zdGFydCA9PSBhZGRyKSAmJgotCQkhdm1hX3N0YWNrX2NvbnRp
bnVlKHZtYS0+dm1fcHJldiwgYWRkcik7CisJcmV0dXJuIHN0YWNrX2d1YXJkX3BhZ2Vfc3RhcnQo
dm1hLCBhZGRyKSB8fAorCSAgICAgICBzdGFja19ndWFyZF9wYWdlX2VuZCh2bWEsIGFkZHIrUEFH
RV9TSVpFKTsKIH0KIAogLyoqCkBAIC0xNTUxLDEyICsxNTUwLDYgQEAgaW50IF9fZ2V0X3VzZXJf
cGFnZXMoc3RydWN0IHRhc2tfc3RydWN0ICp0c2ssIHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLAogCQkJ
Y29udGludWU7CiAJCX0KIAotCQkvKgotCQkgKiBGb3IgbWxvY2ssIGp1c3Qgc2tpcCB0aGUgc3Rh
Y2sgZ3VhcmQgcGFnZS4KLQkJICovCi0JCWlmICgoZ3VwX2ZsYWdzICYgRk9MTF9NTE9DSykgJiYg
c3RhY2tfZ3VhcmRfcGFnZSh2bWEsIHN0YXJ0KSkKLQkJCWdvdG8gbmV4dF9wYWdlOwotCiAJCWRv
IHsKIAkJCXN0cnVjdCBwYWdlICpwYWdlOwogCQkJdW5zaWduZWQgaW50IGZvbGxfZmxhZ3MgPSBn
dXBfZmxhZ3M7CkBAIC0xNTczLDYgKzE1NjYsMTEgQEAgaW50IF9fZ2V0X3VzZXJfcGFnZXMoc3Ry
dWN0IHRhc2tfc3RydWN0ICp0c2ssIHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLAogCQkJCWludCByZXQ7
CiAJCQkJdW5zaWduZWQgaW50IGZhdWx0X2ZsYWdzID0gMDsKIAorCQkJCS8qIEZvciBtbG9jaywg
anVzdCBza2lwIHRoZSBzdGFjayBndWFyZCBwYWdlLiAqLworCQkJCWlmIChmb2xsX2ZsYWdzICYg
Rk9MTF9NTE9DSykgeworCQkJCQlpZiAoc3RhY2tfZ3VhcmRfcGFnZSh2bWEsIHN0YXJ0KSkKKwkJ
CQkJCWdvdG8gbmV4dF9wYWdlOworCQkJCX0KIAkJCQlpZiAoZm9sbF9mbGFncyAmIEZPTExfV1JJ
VEUpCiAJCQkJCWZhdWx0X2ZsYWdzIHw9IEZBVUxUX0ZMQUdfV1JJVEU7CiAJCQkJaWYgKG5vbmJs
b2NraW5nKQo=
--0016e6d58af1b884e304a2df1234--
