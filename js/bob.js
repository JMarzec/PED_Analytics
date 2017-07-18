/* Javascript methods for the Tissue Finder 2.0 *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: all the javascript behaviours of the BOB portal, are included here. */

// loading frame
var loading = "<center>\
                <h2>Loading results, please wait...</h2>\
                <img src='../images/loading.svg' alt='Loading'>\
              </center>";

// webiste for loading iframe
var iframe_url = "http://www.analytics.pancreasexpression.org/ped_backoffice/tmp/";


function LoadHomePage() {
  $("#source.container").load("home.php");
  $("#source.container").show();
  //console.log("LoadHomePage");
}

function LoadSelector() {
	$(".analysis_sel").button();
    $(".analysis_sel").click(function() {
        var clickedId = $(this).attr("id");
        //$("#main.container").hide();
        //$("#main.container").empty(); // emptying all the items inside the div
        $("#results.container").empty(); // emptying all the items inside the div
        $("#main.container").load(""+clickedId+".php", function(){
          $("#description.container").hide("slow");
          $("#main.container").show();
        });
    });
}

function LoadMenuSelector() {
  $("a.menu_btn").click(function(event) {
    $("#source.container").hide();
    var clickedId = $(this).attr("id");
    var text = $("#source.container").load(""+clickedId+".php");
    $("#source.container").html();
    $("#source.container").show();
    event.preventDefault();
  });
}

function LoadPapersTable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var papersTable = $('#papers').DataTable( {
			"order": [[ 4, "asc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_literature.php",
				"type":"post"
			},
			"columnDefs": [
            {
                "targets": [ 5 ],
                "visible": false
            },
            {
                "targets": [ 4 ],
                "visible": false
            }
			]
		});

    yadcf.init(papersTable, [{
      column_number: 3,
      filter_type: "range_date",
      date_format: "yy-mm-dd",
      filter_container_id: "pubdate_filter",
      filter_plugin_options: {
        changeMonth: true,
        changeYear: true
      }
    },
    {
      column_number: 1,
      filter_type: "text",
      filter_container_id: "kw_filter",
    },
    {
      column_number: 5,
      filter_type: 'multi_select_custom_func',
      custom_func: cumulative,
      select_type: 'chosen',
      text_data_delimiter: ',',
      filter_container_id: 'bioinfo_filter',
    }]);

	// highlight selected rows
	$('#papers tbody').on( 'click', 'tr', function () {
		$("#analysis_button").show();
		if ( $(this).hasClass('selected') ) {
				$(this).removeClass('selected');
		}
		else {
				papersTable.$('tr.selected').removeClass('selected');
				$(this).addClass('selected');
		}
	});

		// FILTERING SECTION //

		// autocomplete on MeSH terms
		var options = {
			url: "scripts/RetrieveMeshTerms.php",
			getValue: "Keyword",
			list: {
				match: {
					enabled: true
				},
				onClickEvent: function() {
					var selectedID = $("#mesh_filter").getSelectedItemData().ID;
					papersTable.fnClearTable();
					$.ajax( {
						url:"scripts/FilterData.php?mesh_id="+selectedID+"",
						type:"get",
						dataType:"json",
						beforeSend: function()
						{
							$('#right.literature').hide('slow');
						},
						success: function(data) {
							// showing resulting table
							$('#right.literature').show('slow');
							// now we fill the table again with new filtered values
							papersTable.fnAddData(data['data']);
						}
					});
				}
			},
			template: {
				type: "description",
				fields: {
					description: "Occurrences"
				}
			}
		};

		$("#mesh_filter").easyAutocomplete(options);

    $("#run").button();
			$("#run").click(function(e) {
        var PMID = $('table#papers tr.selected').children().eq(0).text();
        $("#results.container").load("scripts/loading_results.php?pmid="+PMID+"");
        $("#results.container").show();
		});

		$("#filter").accordion({
			 heightStyle: "content",
			 multiple: true,
			 collapsible: true
		});
}

function LoadCCLETable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var ccleTable = $('table#ccle').DataTable( {
			"order": [[ 4, "asc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_ccle.php",
				"type":"post"
			}
		});
}

function LoadTCGATable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var tcgaTable = $('table#tcga').DataTable( {
			"order": [[ 4, "asc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_tcga.php",
				"type":"post"
			}
		});
}

function LoadbcntbreturnTable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();
		// INITIALISING DATA TABLE //
		var LoadbcntbreturnTable = $('table#bcntbreturn').DataTable( {
			"order": [[ 4, "asc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_bcntbReturn.php",
				"type":"post"
			}
		});
}


// function to Load Tabs
function LoadResultTabs(cont) {
  $("#tabs_s"+cont+"").tabs();
}

function LoadCCLETabs() {
  $("#ccle_results.container").tabs();
}

function LoadTCGATabs() {
  $("#tcga_results.container").tabs();
}

// function to load MultiGeneSelector
// this function takes as input the name of html element to call,
// the array express id and PMID id (to call the right expression matrix)
function LoadGeneSelector(el_name, ae, pmid, type_analysis) {

  $.fn.select2.defaults.set("theme", "classic");
  $.fn.select2.defaults.set("ajax--cache", false);

  // we decided to implement an ajax-based search
  $( "#"+el_name+"" ).select2({
    width:'50%',
    //maximumSelectionSize: 50,
    ajax: {
      url: "scripts/RetrieveGeneList.php?ae="+ae+"&pmid="+pmid+"&type_analysis="+type_analysis+"",
      dataType: "json",
      delay: 250,
      data: function (params) {
        return {
          q: params.term, // search term
        };
      },
      processResults: function (data, params) {
        return {
          results: data
        };
        var q = '';
      },
      cache: false
    }
  });
}

// this function launch the Rscript to create the expression profile plot for the selected gene
// the function takes three parameter
// -- el_name: html element to call
// -- ae: array_express id
// -- pmid : pubmed id
// Please note, for security reasons, the launch of Rscript and all system commands are delegated to
// a php function ("LaunchCommand.php")
function LoadAnalysis(genebox, el_name, ae, pmid, type_analysis, cont) {
  var random_code = Math.random().toString(36).substring(7);
  if (type_analysis == "gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+gene+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $(".expression_profile_container").html(loading);
        },
        success: function(data) {
          $(".expression_profile_container").hide();
          $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
          $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
        }
      });
    });
  } else if (type_analysis == "co_expression") {
    $("#"+el_name+"").click(function() {
      var genes = $("#"+genebox+"").select2("val");
      var genes_string = genes.join(",");

      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+genes_string+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $(".coexpression_container").html(loading);
        },
        success: function(data) {
          $(".coexpression_container").hide();
          $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
        }
      });
    });
  } else if (type_analysis == "survival") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();
      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+gene+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $(".survival_container").html(loading);
        },
        success: function(data) {
          $(".survival_container").html("<center><img src='"+iframe_url+random_code+"_KMplot.png'></center>");
        }
      });
    });
  } else if (type_analysis == "ccle_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();
      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $("#gea_ccle").html(loading);
        },
        success: function(data) {
          $("#gea_ccle").hide();
          $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
          $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
        }
      });
    });
  } else if (type_analysis == "ccle_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes = $("#"+genebox+"").select2("val");
      var genes_string = genes.join(",");

      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $("#cea_ccle").html(loading);
        },
        success: function(data) {
          $("#cea_ccle").hide();
          $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
        }
      });
    });
  } else if (type_analysis == "ccle_expression_layering") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();
      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $("#el_ccle").html(loading);
        },
        success: function(data) {
          $("#el_ccle").hide();
          $("iframe#"+genebox+"_boxel.results").attr("src", ""+iframe_url+random_code+"_mRNA_vs_CN_boxplot.html");
          $("iframe#"+genebox+"_el.results").attr("src", ""+iframe_url+random_code+"_mRNA_vs_CN_plot.html");
          $("iframe#"+genebox+"_boxel_mut.results").attr("src", ""+iframe_url+random_code+"_mRNA_vs_CN_mut_boxplot.html");
          $("iframe#"+genebox+"_el_mut.results").attr("src", ""+iframe_url+random_code+"_mRNA_vs_CN_mut_plot.html");
        }
      });
    });
  } else if (type_analysis == "tcga_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();
      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $("#gea_tcga").html(loading);
        },
        success: function(data) {
          $("#gea_tcga").hide();
          $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
          $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
        }
      });
    });
  } else if (type_analysis == "tcga_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes = $("#"+genebox+"").select2("val");
      var genes_string = genes.join(",");

      // launching ajax call to retrieve the expression plot for the selected gene
      $.ajax( {
        url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
        type:"get",
        beforeSend: function()
        {
          $("#cea_tcga").html(loading);
        },
        success: function(data) {
          $("#cea_tcga").hide();
          $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
        }
      });
    });
  }
}

// this function load the Tumor purity data table to visualise samples and
// giving the possibility to filter according to the tumor purity Estimate score
function LoadEstimateDataTable(el_name) {
  var EstimateTable = $("#"+el_name+"").DataTable();
  yadcf.init(EstimateTable, [{
    column_number: 2,
    filter_type: "range_number_slider",
  }]);
}

// Function for cumulative_filtering in analysis
function cumulative(filterVal, columnVal) {
	if (filterVal === null) {
  	return true;
  }
	if (filterVal){
		var found;
		var myElement;
		var foundTout = 0;
		var nbElemSelected = filterVal.length;

      for (i=0; i<nbElemSelected; i++)
      {
          myElement = filterVal[i];
          switch (myElement) {
            case "Gene expression":found = columnVal.search(/Gene expression/g);
            break;
            case "Gene expression correlation":found = columnVal.search(/Gene expression correlation/g);
            break;
            case "Molecular classification":found = columnVal.search(/Molecular classification/g);
            break;
            case "PCA":found = columnVal.search(/PCA/g);
            break;
            case "Receptor status":found = columnVal.search(/Receptor status/g);
            break;
            case "Survival analysis":found = columnVal.search(/Survival analysis/g);
            break;
            case "Tumour purity":found = columnVal.search(/Tumour purity/g);
            break;
          } //close switch
          if (found !== -1) {foundTout++;}
      } // close for
      if (foundTout == filterVal.length) {return true;}
      else {return false;}
	} //close if(filterVal)
} //close myCustomFilterFunction()

// function for scrolling page into specific div
function ascrollto(id) {
	var etop = ($(id).offset().top)+2000;
	$(document).animate({
	  scrollTop: etop+500
	}, 1000);
}

// function for loading the documentation accordion
function LoadDocAcc() {
  $("#doc_acc").accordion({
    heightStyle: "content"
  });
}

// function for loading the results accordion
function LoadResultAcc() {
  $("#res_acc").accordion({
    heightStyle: "content",
    active: false,
    collapsible: true
  });
}
