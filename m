From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 24 Jan 2001 23:52:29 +0000
Subject: Re: [Linux-ia64] Announce: IA-64 cross compiler on IA-32 available
Message-Id: <marc-linux-ia64-105590693005092@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Jan 2001 10:27:05 +1100, 
Keith Owens <kaos@ocs.com.au> wrote:
>On Wed, 24 Jan 2001 10:49:39 -0700 (MST), 
>Khalid Aziz <khalid@lyra.fc.hp.com> wrote:
>>I recently built the latest version of IA-64 cross compiler on IA-32
>>with all of the patches that have been posted on this mailing list. I
>>have made the binaries available at
>><ftp://puffin.external.hp.com/pub/ia64/gcc-2.96-ia64-000717-snap001117-build2.tar.gz>.
>
>This version of gcc invokes 'as' without a path name so it picks up the
>standard ia32 assembler instead of the cross assembler.  This is
>strange, it invokes 'cc1' with the correct path but not 'as'.

Ignore previous mail.  It was a directory permission problem, several
directories unpack with no execute permission for other.  Q&D fix.

  find /opt/ia64/ -type d | xargs chmod a+x


