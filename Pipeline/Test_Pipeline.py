from Book import Book, Library
 
def test_add_book():
     lib = Library()
     book = Book("Python","willi")
    
     lib.add_book(book)
     
     assert len(lib.books) == 1

def test_borrow_book():
    lib = Library()
    book = Book("Python", "Willi")
    
    lib.add_book(book)
    
    result = lib.borrow_book("Python")
    
    assert result == "Livre emprunté"
    assert book.is_available == False