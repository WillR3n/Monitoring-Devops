class Pipeline : # Il s'agit d'un nouveau type d'objet avec Pipeline comme modele 
    def __init__(self, title, author):
        self.title = title
        self.author = author
        self.is_available = True

class Library : 
    def __init__(self):
        self.books = []
        
    def add_book(self, book) :
        self.books.append(book)
        
    def borrow_book(self, title):
        for book in self.books:
            if book.title == title and book.is_available:
                book.is_available = False
                return "Livre emprunte"
        return "Livre non disponible" 
    
    def return_book(self, title):
        for book in self.books:
            if book.title == title:
                book.is_available = True
        return "Livre retourné"
    