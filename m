From: n0ano@indstorage.com
Date: Thu, 25 Oct 2001 14:36:06 +0000
Subject: Re: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Yeah, I know that NT uses a P64 model but if you'll look at
the caption of the slide in question it is for `Linux Device
Drivers'.  Anyone who typedef's `ULONG' to anything other than=20
a 64-bit long on IA64 Linux deserves the confusion that that
will create.

Actually, I believe I was at John's presentation of this slide
set and I'm pretty sure he clarified all of this during his
talk.  This just points out the danger of looking at just a
set of slides.  Without the author to explain things it can
be easy to misinterpret things.

On Thu, Oct 25, 2001 at 09:12:51AM +0800, Tang, Yu wrote:
> /* size.c */
> #include "stido.h"
> int main(int argc, char *argv[])
> {
> 	printf("%d,%d\n",sizeof(unsigned long),sizeof(void*));
> 	return 0;
> }
>=20
> under linux:
> $gcc size.c -o size
> $./size
> 8,8
>=20
> under 64-bit WinXP:
> c:\temp\size
> 4,8
>=20
> -----Original Message-----
> From: KOCHI, Takayoshi [mailto:t-kouchi@mvf.biglobe.ne.jp]
> Sent: 2001=E5=B9=B410=E6oe^25=E6-=A5 3:50
> To: linux-64
> Subject: Re: [Linux-ia64] C union on ia-64
>=20
>=20
> > PS: Interestingly enought, I believe Intel's slide is actually
> > wrong.  If `ULONG' is an `unsigned long' and `PVOID' is a `void *'
> > then all of the data items have the same size and the two structures
> > can be used interchangably on either IA32 or IA64.  It's a
> > dangerous technique but it would work in this case.
>=20
> I believe win64 uses P64 for its programming model.
> (while we use LP64 instead)
> So their ULONG is still 32bit in IA64.
>=20
> Regards,
> --=20
> KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

