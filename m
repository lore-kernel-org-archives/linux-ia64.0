From: John Keller <jpk@sgi.com>
Date: Fri, 16 Feb 2007 13:53:51 +0000
Subject: Re: [PATCH 1/1] -  acpi_unload_table_id() always returns error
Message-Id: <200702161353.l1GDrq4q413863@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200702152329.55535.lenb@kernel.org>
In-Reply-To: <200702152329.55535.lenb@kernel.org> from "Len Brown" at Feb 15, 2007 11:29:55 PM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: John Keller <jpk@sgi.com>, linux-acpi@vger.kernel.org, ayoung@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Yes.

      I understand and agree this project and the contribution
      are public and that a record of the contribution (including all
      personal information I submit with it, including my sign-off) is
      maintained indefinitely. I thereby license this patch to be
      redistributed under any license (GPL or non-GPL) consistent
      with the project.

John


> 
> Thanks for the fix, John.
> Do you grant Intel permission to apply it to the upstream ACPICA tree (with its non-GPL license)?
> 
> -Len
> 
> On Thursday 15 February 2007 15:08, John Keller wrote:
> > acpi_unload_table_id() is always returning an error status.
> > Also, once the matching table is found, don't bother looking
> > for another match.
> > 
> > 
> > Signed-off-by: John Keller <jpk@sgi.com>
> > ---
> > 
> > 
> > Index: release/drivers/acpi/tables/tbxface.c
> > =================================> > --- release.orig/drivers/acpi/tables/tbxface.c	2007-02-13 08:20:42.000000000 -0600
> > +++ release/drivers/acpi/tables/tbxface.c	2007-02-15 14:04:07.855248010 -0600
> > @@ -338,9 +338,9 @@ acpi_status acpi_unload_table_id(acpi_ow
> >  	int i;
> >  	acpi_status status = AE_NOT_EXIST;
> >  
> > -	ACPI_FUNCTION_TRACE(acpi_unload_table);
> > +	ACPI_FUNCTION_TRACE(acpi_unload_table_id);
> >  
> > -	/* Find table from the requested type list */
> > +	/* Find table in the global table list */
> >  	for (i = 0; i < acpi_gbl_root_table_list.count; ++i) {
> >  		if (id != acpi_gbl_root_table_list.tables[i].owner_id) {
> >  			continue;
> > @@ -352,8 +352,9 @@ acpi_status acpi_unload_table_id(acpi_ow
> >  		* simply a position within the hierarchy
> >  		*/
> >  		acpi_tb_delete_namespace_by_owner(i);
> > -		acpi_tb_release_owner_id(i);
> > +		status = acpi_tb_release_owner_id(i);
> >  		acpi_tb_set_table_loaded_flag(i, FALSE);
> > +		break;
> >  	}
> >  	return_ACPI_STATUS(status);
> >  }
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

