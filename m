From: Khalid Aziz <khalid@fc.hp.com>
Date: Thu, 25 Jan 2001 01:12:18 +0000
Subject: Re: [Linux-ia64] Announce: IA-64 cross compiler on IA-32 available
Message-Id: <marc-linux-ia64-105590693005094@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Ignore previous mail.  It was a directory permission problem, several
> directories unpack with no execute permission for other.  Q&D fix.
> 
>   find /opt/ia64/ -type d | xargs chmod a+x

Thanks for finding the problem. I have fixed the directory permissions
and uploaded the new tar file at
<ftp://puffin.external.hp.com/pub/ia64/gcc-2.96-ia64-000717-snap001117-build3.tar.gz>

-- 
Khalid

==================================
Khalid Aziz                             Linux Development Laboratory
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO

