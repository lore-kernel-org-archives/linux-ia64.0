From: Steffen Persvold <sp@scali.com>
Date: Tue, 06 Aug 2002 15:44:40 +0000
Subject: Re: [Linux-ia64] 2.4.9 vs 2.4.18 for HPC
Message-Id: <marc-linux-ia64-105590701905913@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905912@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905912@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 6 Aug 2002, Egan Ford wrote:

> With respect to Itanium2 what advantages does 2.4.18 have over 2.4.9 in
> an HPC environment?
> 
> My concern is that RH7.2 does not have a 2.4.18/19 kernel and probably
> will not.  For support reasons, running 2.4.9-34 from RH may be
> required.  I am curious about the possible performance and stability
> issues with 2.4.9 on Itanium2.
> 
> I am trying to build a case for software development on 2.4.18/19
> kernel.org kernels.
> 

I don't think RH 7.2 2.4.9 kernels will run on Itanium2. You'll need 
atleast 2.4.18 + the latest patchset from David.

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


