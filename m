From: Jim Blandy <jimb@zwingli.cygnus.com>
Date: Tue, 07 Nov 2000 22:28:17 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205663@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't think limiting the caching to C++ programs solves the problem.

If I understand the situation, the SGI compiler attaches a DW_AT_name
attribute to array types.  We don't know whether this behavior occurs
only in C compilation units, or in C++ compilation units as well.

If the SGI compiler emits bogus names for array types in C++ code too,
then the same bug will reappear when debugging C++ code, even with
this patch applied.

I think the change to tag_type_to_type needs to be reverted
altogether.  I understand that it provides substantial savings in
storage, but it's simply not correct.

