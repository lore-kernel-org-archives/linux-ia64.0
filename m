From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 01 May 2001 22:51:29 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related orphans from Configure.help
Message-Id: <marc-linux-ia64-105590693005508@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005460@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 1 May 2001 08:49:10 -0700, 
"Chris McDermott" <mcdermoc@us.ibm.com> wrote:
>Actually, CONFIG_ITANIUM_PTCG is still required if you have systems with
>Itanium
>processor steppings less than B3. I still have some of these and I'm sure
>there are
>quite a few others out there who still do as well.

Configure.help is designed for humans to query what an option does
while they are configuring the system.  CONFIG_ITANIUM_PTCG is a
derived setting, humans have no direct control over it and it never
appears on a config menu.  Help text is not required for derived config
settings and is discouraged.


