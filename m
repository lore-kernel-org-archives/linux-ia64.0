From: Keith Owens <kaos@sgi.com>
Date: Sun, 20 Jan 2002 00:15:18 +0000
Subject: [Linux-ia64] Re: [RFC] NUMA functions for accessing replicated areas
Message-Id: <marc-linux-ia64-105590698805891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805887@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805887@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 19 Jan 2002 18:02:20 -0600 (CST), 
Jack Steiner <steiner@sgi.com> wrote:
>There is one thing that occurred to me. Currently, on IA64, the replicated
>data is read-execute. The NUMA code known how to write it but I dont
>know if you want to teach kdb how to do it.

That is exactly what I don't want to do.  I want numa_putarea_size to
take a virtual target address and copy the data to all instances of
that target address.  kdb should not know about translating one to
many, the numa functions hide that complexity from anything that needs
to update replicated data.


