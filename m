From: "Luming Yu" <luming.yu@gmail.com>
Date: Fri, 23 May 2008 12:33:14 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805230533u73c3d09agacf94d80bf99a0bb@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_7706_7605130.1211545994533"
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
	 <1211458368.5610.36.camel@elijah.suse.cz>
In-Reply-To: <1211458368.5610.36.camel@elijah.suse.cz>
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

------=_Part_7706_7605130.1211545994533
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, May 22, 2008 at 8:12 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> On Thu, 2008-05-22 at 04:18 -0700, Roland McGrath wrote:
>> I really cannot figure out from anything you've said what the failure mode
>> is or how you think it should be affected.
>
> At least you should be able to see the related bug report at:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=446200
>
> I'm getting Access Denied. :(

ok , I just got permit to share the test case here..  Please check out
the attachment.
 1. tar jxvf testpro.tar.bz2
       testpro/test1.c
               test2.sh
2.cd testpro
3.gcc -o test1 test1.c
4.strace -f -o log.txt ./test1

hope you can reproduce the problem.

Thanks,
Luming

------=_Part_7706_7605130.1211545994533
Content-Type: application/x-bzip2; name=testpro.tar.bz2
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fgkqq5bd0
Content-Disposition: attachment; filename=testpro.tar.bz2

QlpoOTFBWSZTWY3ES1YAAn1/lc6wAIB7d/+PM69+Xv/v3/oAEAABAEAACEACaCkQqEkqbUyExpqZ
MTTammmjIGmgaNMgBiNBppoCRJATTIaTKeU00zU0GhpkaANA0epoaZDIDjI0yYmgyZMJpkDIaA0B
pk0MAJoDHGRpkxNBkyYTTIGQ0BoDTJoYATQGwLvxVKpH/PpicwhNKQJFew/YYeE88xC6WgfFqpiA
iGVCWRpSZCQwYxsGmHv6urtuIhiY1xbeukmU7ocsqgDN35pQEGqjErgm5lBG7zj1l5RijJLfWAtg
jKjXtNtvHLBmLbU4LoMLyGGq6itkhkzr+8VSnsH3N6kz88l/TOG9LQ7ObKYi3JBFJEqJWzrN0QTE
+Dlv2xzaJjxvGcdMiirDTO3dTpmNy0Y0YpsA02Oc+nSs1LND88A1Fbi2OWsSS/YhKoJitWHgF42x
bPLAvVwcJoVn2Vi9ZprVvWZ7LPPLiw12KKRYC70zzk5iiosxSnLZlKdzEQXSVrExlhCkBlSIZP2o
C0ykaiLwzMK6hvQPOLG4y3MaHCc10kmV1dvIKI4Mzgk5H3jJlDL6kyfeS5s/WUo4xmbbzTr4plyc
vsWGTneM8MCsqnggLLIm6RS+0jlK/UULnYYmRgRgmB7V6LJStm6UTmOuIR8eOe/PLkc7DL1XmxVQ
WC3ypWoxl6J3FwUgYMsyVrTrWdHIsHYeTAi2x1CL5bHIa0W9f5VktFhfoDARuLoWPGq22jLmsrkj
aGiL+Akwmo6RoNPggVgVIogOHVciqk2DOlWRA/LKNlat28W4D78ocQVnxghCgXjPpiIESKsNq21A
0JolokRAT1TWfqJJkGokPabgkG2oYqbV/f90V4a6g05xbwXZv5U5cIqVBokTa88CBeBvkCN4QH+L
uSKcKEhG4iWrAA==
------=_Part_7706_7605130.1211545994533--
