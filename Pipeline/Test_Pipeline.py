from Pipeline import Pipeline, Library
 
def test_add_book():
     lib = Pipeline()
     book = Pipeline("Python","willi")
    
     lib.add_book(book)
     
     assert len(lib.books) == 1

def test_borrow_book():
    lib = Library()
    book = Pipeline("Python", "Willi")
    
    lib.add_book(book)
    
    result = lib.borrow_book("Python")
    
    assert result == "Livre emprunté"
    assert book.is_available == False