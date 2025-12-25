class KoleksiModel {
  String? fileName;
  List<String>? author;
  List<String>? editor;
  String? publisher;
  String? city;
  String? year;
  String? isbn;
  String? pageCount;
  String? dimension;
  List<String>? keywords;
  List<String>? url;
  String? title;
  String? description;
  String? preface;
  List<TableOfContents>? tableOfContents;
  List<Pages>? pages;
  String? lokasi;

  KoleksiModel(
      {this.fileName,
      this.author,
      this.editor,
      this.publisher,
      this.city,
      this.year,
      this.isbn,
      this.pageCount,
      this.dimension,
      this.keywords,
      this.url,
      this.title,
      this.description,
      this.preface,
      this.tableOfContents,
      this.pages,
      this.lokasi});

  KoleksiModel.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    author = json['author'].cast<String>();
    editor = json['editor'].cast<String>();
    publisher = json['publisher'];
    city = json['city'];
    year = json['year'];
    isbn = json['isbn'];
    pageCount = json['page_count'];
    dimension = json['dimension'];
    keywords = json['keywords'].cast<String>();
    url = json['url'].cast<String>();
    title = json['title'];
    description = json['description'];
    preface = json['preface'];
    if (json['table_of_contents'] != null) {
      tableOfContents = <TableOfContents>[];
      json['table_of_contents'].forEach((v) {
        tableOfContents!.add(TableOfContents.fromJson(v));
      });
    }
    if (json['pages'] != null) {
      pages = <Pages>[];
      json['pages'].forEach((v) {
        pages!.add(Pages.fromJson(v));
      });
    }
    lokasi = json['lokasi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_name'] = fileName;
    data['author'] = author;
    data['editor'] = editor;
    data['publisher'] = publisher;
    data['city'] = city;
    data['year'] = year;
    data['isbn'] = isbn;
    data['page_count'] = pageCount;
    data['dimension'] = dimension;
    data['keywords'] = keywords;
    data['url'] = url;
    data['title'] = title;
    data['description'] = description;
    data['preface'] = preface;
    if (tableOfContents != null) {
      data['table_of_contents'] =
          tableOfContents!.map((v) => v.toJson()).toList();
    }
    if (pages != null) {
      data['pages'] = pages!.map((v) => v.toJson()).toList();
    }
    data['lokasi'] = lokasi;
    return data;
  }
}

class TableOfContents {
  String? title;
  int? pageNumber;

  TableOfContents({this.title, this.pageNumber});

  TableOfContents.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    pageNumber = json['page_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['page_number'] = pageNumber;
    return data;
  }
}

class Pages {
  int? pageNumber;
  String? title;
  String? subtitle;
  String? content;
  String? subTitle;

  Pages(
      {this.pageNumber,
      this.title,
      this.subtitle,
      this.content,
      this.subTitle});

  Pages.fromJson(Map<String, dynamic> json) {
    pageNumber = json['page_number'];
    title = json['title'];
    subtitle = json['subtitle'];
    content = json['content'];
    subTitle = json['sub_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['content'] = content;
    data['sub_title'] = subTitle;
    return data;
  }
}
